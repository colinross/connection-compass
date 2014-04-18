require 'rubygems'
require 'pry'
require 'sinatra/base'
require 'sinatra/contrib'
require 'json'

require 'omniauth'
# require 'omniauth-github'
require 'omniauth-facebook'
# require 'omniauth-twitter'

require "data_mapper"
require "dm-sqlite-adapter"

class ConnectionCompass < Sinatra::Base
  enable :logging
  configure :development do
    require 'sinatra/reloader'
    register Sinatra::Reloader
    DataMapper::Logger.new($stdout, :debug)
  end

  register Sinatra::Contrib
  # register Sinatra::ConfigFile
  config_file File.join(File.dirname(__FILE__),'config','settings.yml')

  DataMapper.setup(:default, settings.database["database"])

  set :session_secret, settings.session_secret
  enable :sessions
  enable :inline_templates

  # load models
  Dir[File.join(File.dirname(__FILE__), 'models', '**/*.rb')].sort.each do |file|
    require file
  end
  DataMapper.auto_upgrade!
  DataMapper.finalize
  

  # FACEBOOK_REQUIRED_TOKEN_SCOPES = "basic_info,email,location"

  use OmniAuth::Builder do
    # provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']
    provider :facebook, ConnectionCompass.settings.services["facebook"]["app_id"], 
                        ConnectionCompass.settings.services["facebook"]["app_secret"]
    # provider :twitter,  ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
  end

  helpers do
    def current_user
      @current_user ||= User.find_by(id: session[:user_id])
    end

    def signed_in?
      !!current_user
    end

    def current_user=(user)
      @current_user = user
      session[:user_id] = user.nil? ? user : user.id
    end
  end

  get '/' do
    erb "
    <a href='/auth/github'>Login with Github</a><br>
    <a href='/auth/facebook'>Login with facebook</a><br>
    <a href='/auth/twitter'>Login with twitter</a><br>
    "
  end
  
  get '/auth/:provider/callback' do
      auth = request.env['omniauth.auth']
      # Find an identity here
      @identity = Identity.find_with_omniauth(auth)

      if @identity.nil?
        # If no identity was found, create a brand new one here
        @identity = Identity.create_with_omniauth(auth)
      end

      if signed_in?
        if @identity.user == current_user
          # User is signed in so they are trying to link an identity with their
          # account. But we found the identity and the user associated with it 
          # is the current user. So the identity is already associated with 
          # this user. So let's display an error message.
          # redirect_to root_url, notice: "Already linked that account!"
          @notice = "Already linked that account!"
        else
          # The identity is not associated with the current_user so lets 
          # associate the identity
          # @identity.user = current_user
          # @identity.save()
          # redirect_to root_url, notice: "Successfully linked that account!"
          @notice = "That is already linked to a different account!"
        end
      else
        if @identity.user.present?
          # The identity we found had a user associated with it so let's 
          # just log them in here
          current_user = @identity.user
          #redirect_to root_url, notice: "Signed in!"
          @notice = "Existing User: Successfully linked that account!"
        else
          # No user associated with the identity so we need to create a new one
          # redirect_to new_user_url, notice: "Please finish registering"
          @notice = "You are a new user and have linked that account!"
        end
      end

    erb "<h1>#{params[:provider]}</h1>
         <div>#{@notice}</div>
         <pre>#{JSON.pretty_generate(request.env['omniauth.auth'])}</pre>"
  end
  
  get '/auth/failure' do
    erb "<h1>Authentication Failed:</h1><h3>message:<h3> <pre>#{params}</pre>"
  end
  
  get '/auth/:provider/deauthorized' do
    erb "#{params[:provider]} has deauthorized this app."
  end
  
  get '/protected' do
    throw(:halt, [401, "Not authorized\n"]) unless signed_in?
    erb "<h3>Some protected page for User #{current_user.id}</h3><pre>#{request.env['omniauth.auth'].to_json}</pre><hr>
         <a href='/logout'>Logout</a>"
  end
  
  get '/logout' do
    current_user = nil
    redirect '/'
  end

end
