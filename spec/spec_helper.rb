ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'bundler/setup'
Bundler.setup


# require test-specific stuff
require 'rack/test'
require 'pry'

# VCR for fast, cached HTTP calls based on real responses
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :faraday
end

# Misc patches as testing helpers
class Hash
  def include_hash?(other)
    other.all? do |other_key_value|
      any? { |own_key_value| own_key_value == other_key_value }
    end
  end
end

# test files should individually require the parts of the app they rely on.
# Don't just Dir.glob the app here please.


# This is the script that runs the full test suite. It is faster and
# more effeciant than pulling in rake just to do this job.
if __FILE__ == $0
  $LOAD_PATH.unshift('lib', 'spec')
  Dir.glob('./spec/**/*_spec.rb').each { |file| require file}
end

require 'minitest/autorun' # run spec/or suite of specs that required this helper
