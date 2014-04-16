require 'sinatra/base'
require 'sinatra/contrib'
require 'pry'

module ConnectionCompass
  class SinatraBaseApp < Sinatra::Base
    register Sinatra::Contrib

    configure :development do
      require 'sinatra/reloader'
      register Sinatra::Reloader
    end

    enable :sessions
    set :session_secret, 'This is a secret key'

  end
end

Dir[File.join(File.dirname(__FILE__), 'app', '**/*.rb')].sort.each do |file|
  require file
end