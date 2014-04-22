require_relative 'base'

module Services
  # Usage: 
  # fb_service = Services::Facebook.new(users_facebook_access_token)
  # fb_service.get_friends  # get hash of friends
  # fb_service.get "/me"
  class Facebook < Base
    # Not directly needed now, but eventualy we should sign all our fb requests with the hash of these,
    # see https://developers.facebook.com/docs/graph-api/securing-requests/
    # make this a call to the settings file without having to include
    # the whole app
    APP_ID = "754336197924702"
    APP_SECRET = "9d1ccd0bed4b0978bea7df6b6b689481"
    APP_ACCESS_TOKEN = "754336197924702|2MRBX58xoXD33FNmtmcsa_ZteyE"
    attr_accessor :access_token

    def initialize(given_access_token)
      access_token = given_access_token
      conn_options = {
        url: "https://graph.facebook.com",  
        params:  {access_token: access_token},
      }
      super(conn_options)
    end

    def verify_access_token!
      response = get '/debug_token' do |req|
        req.params[:access_token] = APP_ACCESS_TOKEN 
        req.params[:input_token] = access_token
      end
      ::JSON.parse(response.body)["data"]["is_valid"]
    end
    def friends
      ::JSON.parse((get %{/me/friends?fields=third_party_id,address,location,name}).body)
    end
  end
end

