require 'rubygems'
require 'bundler/setup'
bundler.setup(:default, ENV["RACK_ENV"].to_sym )

require './connection_compass.rb'

run ConnectionCompass
