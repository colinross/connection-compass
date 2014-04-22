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
  c.default_cassette_options = { :record => :new_episodes }
  c.ignore_request do |req|
    URI(req.uri).path =~ /accounts\/test-users$/ if ENV['RESET_FACEBOOK_TOKENS']
  end
end

# Get new access tokens for test users if ENV['RESET_FACEBOOK_TOKENS']
if !ENV['RESET_FACEBOOK_TOKENS'].nil? || !defined?(FACEBOOK_ACCESS_TOKEN_FOR_TEST_USERS)
  require 'json'
  require_relative '../lib/services/facebook'
  
  client = ::Services::Base.new({url: "https://graph.facebook.com"})
  VCR.use_cassette('facebook_test_users') do
    request = client.get "/#{::Services::Facebook::APP_ID}/accounts/test-users" do |req|
      req.params['access_token'] = ::Services::Facebook::APP_ACCESS_TOKEN
    end
    test_user_info = ::JSON::parse(request.body)

    FACEBOOK_ACCESS_TOKEN_FOR_TEST_USERS = {}
    test_user_info["data"].inject(FACEBOOK_ACCESS_TOKEN_FOR_TEST_USERS) do |results, test_user|
      results[test_user["id"]] = test_user["access_token"] if test_user["access_token"]
      results
    end
  end
end

# ugly i know
def facebook_access_token_for_test_user
  FACEBOOK_ACCESS_TOKEN_FOR_TEST_USERS.first.last
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
