require 'rubygems'
require File.join(File.dirname(__FILE__), 'app.rb')
map "/" do
  run ConnectionCompass::Main
end