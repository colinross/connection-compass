source "https://rubygems.org"

gem 'sinatra'
gem 'sinatra-contrib'

gem 'omniauth'
gem 'omniauth-facebook'

gem "data_mapper"
gem "dm-sqlite-adapter"

gem "moneta"

gem "faraday" # already required from omniauth, but the Service class directly use it as well

group :development, :test do
  gem 'pry'
end

group :development do
  gem 'thin'
end

group :test do
  gem 'minitest'
end