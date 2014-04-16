require 'rubygems'
require 'sinatra/base'
require 'sinatra/contrib'
require 'json'
require 'omniauth'
# require 'omniauth-github'
require 'omniauth-facebook'
# require 'omniauth-twitter'

module ConnectionCompass
  class SinatraBaseApp < Sinatra::Base
    register Sinatra::Contrib
    register Sinatra::ConfigFile

    configure do
      config_file File.join(File.dirname(__FILE__),'config.yaml')

      enable :sessions
      set :session_secret, settings.app.session_secret
      # set :views, File.join(File.dirname(__FILE__),'..','views','main')
      enable :inline_templates
    end

    FACEBOOK_REQUIRED_TOKEN_SCOPES = "basic_info,email,location"

    use OmniAuth::Builder do
      # provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']
      provider :facebook, settings.facebook.api_key, settings.facebook.api_secret
      # provider :twitter,  ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
    end
    get '/' do
      erb "
      <a href='http://localhost:4567/auth/github'>Login with Github</a><br>
      <a href='http://localhost:4567/auth/facebook'>Login with facebook</a><br>
      <a href='http://localhost:4567/auth/twitter'>Login with twitter</a><br>
    end
    
    get '/auth/:provider/callback' do
      erb "<h1>#{params[:provider]}</h1>
           <pre>#{JSON.pretty_generate(request.env['omniauth.auth'])}</pre>"
    end
    
    get '/auth/failure' do
      erb "<h1>Authentication Failed:</h1><h3>message:<h3> <pre>#{params}</pre>"
    end
    
    get '/auth/:provider/deauthorized' do
      erb "#{params[:provider]} has deauthorized this app."
    end
    
    get '/protected' do
      throw(:halt, [401, "Not authorized\n"]) unless session[:authenticated]
      erb "<pre>#{request.env['omniauth.auth'].to_json}</pre><hr>
           <a href='/logout'>Logout</a>"
    end
    
    get '/logout' do
      session[:authenticated] = false
      redirect '/'
    end

    configure :development do
      require 'sinatra/reloader'
      register Sinatra::Reloader
    end

  end
end

# Dir[File.join(File.dirname(__FILE__), 'app', '**/*.rb')].sort.each do |file|
#   require file
# end

__END__

@@ layout
<html>
  <head>
    <link href='http://twitter.github.com/bootstrap/1.4.0/bootstrap.min.css' rel='stylesheet' />
  </head>
  <body>
    <div class='container'>
      <div class='content'>
        <%= yield %>
      </div>
    </div>
  </body>
</html>