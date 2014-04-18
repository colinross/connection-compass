ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'bundler/setup'
Bundler.setup


# require test-specific stuff
require 'rack/test'

# test files should individually require the parts of the app they rely on.
# Don't just Dir.glob the app here please.


# This is the script that runs the full test suite. It is faster and
# more effeciant than pulling in rake just to do this job.
if __FILE__ == $0
  $LOAD_PATH.unshift('lib', 'spec')
  Dir.glob('./spec/**/*_spec.rb').each { |file| require file}
end

require 'minitest/autorun' # run spec/or suite of specs that required this helper
