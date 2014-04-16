require 'rubygems'
require 'sinatra/base'
require 'sinatra/contrib'
require 'json'
require 'omniauth'
# require 'omniauth-github'
require 'omniauth-facebook'
# require 'omniauth-twitter'

module ConnectionCompass
  class App < Sinatra::Base
    register Sinatra::Contrib
    register Sinatra::ConfigFile

    configure do
      config_file File.join(File.dirname(__FILE__),'config.yaml')
      settings
      enable :sessions
      set :session_secret, settings.app["session_secret"]
      # set :views, File.join(File.dirname(__FILE__),'..','views','main')
      enable :inline_templates
    end
    configure :production, :development do
      enable :logging
    end

    configure :development do
      require 'sinatra/reloader'
      register Sinatra::Reloader
    end

    # FACEBOOK_REQUIRED_TOKEN_SCOPES = "basic_info,email,location"

    use OmniAuth::Builder do
      # provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']
      provider :facebook, ConnectionCompass::App.settings.facebook["app_id"], ConnectionCompass::App.settings.facebook["app_secret"]
      # provider :twitter,  ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
    end

    get '/' do
      erb "
      <a href='/auth/github'>Login with Github</a><br>
      <a href='/auth/facebook'>Login with facebook</a><br>
      <a href='/auth/twitter'>Login with twitter</a><br>
      "
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

  end
end

# Dir[File.join(File.dirname(__FILE__), 'app', '**/*.rb')].sort.each do |file|
#   require file
# end

