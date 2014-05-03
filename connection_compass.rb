require 'rubygems'
require 'pry'
require 'sinatra/base'
require 'sinatra/contrib'
require 'sinatra/flash'
require 'json'

require 'omniauth'
# require 'omniauth-github'
require 'omniauth-facebook'
# require 'omniauth-twitter'

require "data_mapper"
require "dm-sqlite-adapter"

require 'rack/session/moneta'

#Dir[File.dirname(__FILE__) + '/lib/**/*.rb'].each {|file| require file }
require_relative 'lib/services/base'

class ConnectionCompass < Sinatra::Base
  enable :logging
  enable :inline_templates
  enable :sessions
  register Sinatra::Flash
  set :session_secret, settings.session_secret

  configure do
    file = File.new("#{settings.root}/log/#{settings.environment}.log", 'a+')
    file.sync = true
    use Rack::CommonLogger, file
  end
  configure :development do
    require 'sinatra/reloader'
    register Sinatra::Reloader
    DataMapper::Logger.new($stdout, :debug)
  end

  register Sinatra::Contrib
  # register Sinatra::ConfigFile
  config_file File.join(File.dirname(__FILE__),'config','settings.yml')

  DataMapper.setup(:default, settings.database["database"])
  # load models
  Dir[File.join(File.dirname(__FILE__), 'models', '**/*.rb')].sort.each do |file|
    require file
  end
  DataMapper.auto_upgrade!
  DataMapper.finalize

  # KISS: use the sqlite db for session store as well for proof-of-concept
  use Rack::Session::Moneta,
     store: Moneta.new(:DataMapper, setup: settings.database["database"])

  FACEBOOK_AUTH_SCOPE = "basic_info,user_location,friends_location"
  FACEBOOK_INFO_FIELDS = "name,location,link,id,picture,timezone,third_party_id"

  use OmniAuth::Builder do
    # provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']
    provider :facebook, ConnectionCompass.settings.services["facebook"]["app_id"], 
                        ConnectionCompass.settings.services["facebook"]["app_secret"],
                        {scope: FACEBOOK_AUTH_SCOPE, info_fields: FACEBOOK_INFO_FIELDS,
                         image_size: :normal, secure_image_url: true, }
    # provider :twitter,  ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
  end

  helpers do
    def current_user
      @current_user ||= User.first(id: session['user_id'])
    end
  end

  get '/' do
    binding.pry
    erb "<a href='/auth/facebook'>Login with facebook</a><br>"
  end
  
  get '/auth/:provider/callback' do
    auth = request.env['omniauth.auth']
    # Hi security bug-- should really do this via a session hash => user association
    # Next phase i should pull in warden to handle the logic
    current_user ||= User.first(id: session['user_id'])

    # Find an identity here
    @identity = Identity.find_with_omniauth(auth)
    if @identity.nil?
      # If no identity was found, create a brand new one here
      @identity = Identity.create_with_omniauth(auth)
      unless current_user.nil?
        # Adding a subsequent identity to a user
        @identity.user = current_user
        flash[:notice] = "Existing User: Successfully linked that account!"
      else
        # new user
        current_user = User.create(name: auth['info']['name'])
        flash[:notice] = "You are a new user and have linked that account!"
      end
      @identity.user = current_user
      @identity.save
      current_user.profile = Profile.create_from_facebook_auth_info(auth['info'])
      binding.pry
    end
    session[:user_id] = current_user.id
    redirect '/friends'
  end
  
  get '/auth/failure' do
    erb "<h1>Authentication Failed:</h1><h3>message:<h3> <pre>#{params}</pre>"
  end
  
  get '/auth/:provider/deauthorized' do
    erb "#{params[:provider]} has deauthorized this app."
  end
  
  get '/oauth_debug' do
    throw(:halt, [401, "Not authorized\n"]) unless signed_in?
    erb "<h3>Some protected page for User #{current_user.id}</h3><pre>#{request.env['omniauth.auth'].to_json}</pre>"
  end

  get '/friends' do
    @fb_identity = Identity.first(user: current_user, provider: "facebook")
    @fb_service = ::Services::Facebook.new(@fb_identity.access_token)
    binding.pry
    @friends_close_to_location = @fb_service.friends_close_to_location(session[:facebook_info]["location"].to_a[1..2].join(",")) 
    erb :friends 
  end
  
  get '/logout' do
    session['user_id'] = current_user = nil
    redirect '/'
  end

end
