require 'rubygems'
require 'bundler/setup'
Bundler.setup(:default, ENV["RACK_ENV"].to_sym )

require './connection_compass.rb'

run ConnectionCompass
