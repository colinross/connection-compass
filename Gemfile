source "https://rubygems.org"
ruby "1.9.3"

gem 'sinatra'
gem 'sinatra-contrib'
gem 'sinatra-flash'

gem 'omniauth'
gem 'omniauth-facebook'

gem "data_mapper"
gem 'dm-postgres-adapter', :group => :production
gem 'dm-sqlite-adapter', :group => :development

gem "moneta"

gem 'geokit'

gem "faraday", "0.8.9" #see: https://github.com/vcr/vcr/issues/386
gem 'faraday-http-cache'

group :development, :test do
  gem 'pry'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
end

group :test do
  gem 'simplecov'
  gem 'vcr'
  gem 'minitest'
end

