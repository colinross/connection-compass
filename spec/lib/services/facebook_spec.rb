require_relative '../../spec_helper'
require_relative '../../../lib/services/facebook'

describe Services::Facebook do
  before do
    @fb_service = Services::Facebook.new(FACEBOOK_ACCESS_TOKEN_FOR_TEST_USERS.first.last)
  end
  it "should be able to verify an access token" do
    VCR.use_cassette('lib_services_facebook', :record => :new_episodes) do
      assert @fb_service.verify_access_token!
    end
  end
  it "should be able to get a list of friends" do
    VCR.use_cassette('lib_services_facebook', :record => :new_episodes) do
      friends = @fb_service.friends
      binding.pry
    end
  end
end
