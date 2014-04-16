require_relative '../app'
require 'omniauth'

module ConnectionCompass
  class Main < SinatraBaseApp
    use OmniAuth::Builder do
      provider :developer unless Sinatra::Base.settings.production?
    end    
    set :views, File.join(File.dirname(__FILE__),'..','views','main')
    get '/' do
      'I Am Legion'
    end
  end
end