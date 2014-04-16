source "https://rubygems.org"

gem 'sinatra'
gem 'sinatra-contrib'

gem 'omniauth'
gem 'omniauth-facebook'

# Database (using AR+SQLite for spikage)
# gem "activerecord" # See: https://github.com/janko-m/sinatra-activerecord/issues/29
gem "sinatra-activerecord", github: "janko-m/sinatra-activerecord", ref: "c0c328d47057d067a1cc7ad8bb76d353d91fb8e6"
gem "sqlite3"
gem "rake"


group :development, :test do
  gem 'pry'
end

group :development do
  gem 'thin'
end

group :test do
  gem 'minitest', '~> 4.2'
end