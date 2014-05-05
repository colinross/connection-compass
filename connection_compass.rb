require 'rubygems'
require 'bundler/setup'
Bundler.require(:default, ENV["RACK_ENV"].to_sym )
require 'rack/session/moneta'


Dir[File.dirname(__FILE__) + '/lib/**/*.rb'].each {|file| require file }

class ConnectionCompass < Sinatra::Base
  configure :development do
    require 'sinatra/reloader'
    register Sinatra::Reloader
  end

  DATABASE_URL = ENV['DATABASE_URL'] ||  "sqlite3:db/development.sqlite3"
  DataMapper.setup(:default, DATABASE_URL)
  configure do
    enable :inline_templates
    enable :sessions
    register Sinatra::Flash
    register Sinatra::Contrib
    config_file File.join(File.dirname(__FILE__),'config','settings.yml')
    set :session_secret, settings.session_secret

    enable :logging
    if ENV["RACK_ENV"] == 'production'
      file = STDOUT
    else
      file = File.new("#{settings.root}/log/#{settings.environment}.log", 'a+')
    end
    file.sync = true
    use Rack::CommonLogger, file
    DataMapper::Logger.new($stdout, :error)
  end
  use PryRescue::Rack if ENV["RACK_ENV"] == 'development'

  # load models
  Dir[File.join(File.dirname(__FILE__), 'models', '**/*.rb')].sort.each do |file|
    require file
  end
  DataMapper.auto_upgrade!
  DataMapper.finalize

  use Rack::Session::Moneta,
     store: Moneta.new(:DataMapper, setup: DATABASE_URL)

  FACEBOOK_AUTH_SCOPE = "public_profile,user_friends,user_location,friends_location"
  FACEBOOK_INFO_FIELDS = "name,location,link,third_party_id"

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
    if current_user.nil?
      erb %{<a class="center-block btn btn-lg btn-primary" href='/auth/facebook' role="button">Login with Facebook</a>}
    else
      redirect '/friends'
    end
  end
  
  get '/auth/:provider/callback' do
    auth = request.env['omniauth.auth']
    # Hi security bug-- should really do this via a session hash => user association
    # Next phase i should pull in warden to handle the logic
    current_user shoul dget reset according to 
    current_user ||= User.first(id: session['user_id'])
    session[:user_id] = current_user.id if !current_user.nil?
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
        current_user = User.create
        session[:user_id] = current_user.id
        flash[:notice] = "You are a new user and have linked that account!"
      end
      @identity.user = current_user
      @identity.save
      Profile.create_from_facebook_auth_info(current_user, auth)
    end
    redirect '/friends'
  end
  
  get '/auth/failure' do
    erb "<h1>Authentication Failed:</h1><h3>message:<h3> <pre>#{params}</pre>"
  end
  
  get '/auth/:provider/deauthorized' do
    erb "#{params[:provider]} has deauthorized this app."
  end

  get '/friends' do
    @fb_identity = Identity.first(user: current_user, provider: "facebook")
    @fb_service = ::Services::Facebook.new(@fb_identity.access_token)
    unless params[:center_override].nil?
      @center = Geokit::Geocoders::GoogleGeocoder.geocode(params[:center_override]).ll.split(",")
    else
      @center = [current_user.profile.location_lat,current_user.profile.location_long]
    end
    @friends =  @fb_service.friends_by_location(@center, 30) # miles
    erb :friends 
  end
  
  get '/logout' do
    session['user_id'] = current_user = nil
    redirect '/'
  end

end
