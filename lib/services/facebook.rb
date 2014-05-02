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

    # CLASS Methods
    class <<self 
      def _app_api_client
        @@app_api_client ||= new(APP_ACCESS_TOKEN)
      end
      def verify_access_token!
        response = _app_api_client.get '/debug_token' do |req|
          req.params[:input_token] = access_token
        end
        ::JSON.parse(response.body)["data"]["is_valid"]
      end
      def coordinates_for_location_id(location_id)
        @@location_coordinates.fetch(location_id.to_s) || @@location_coordinates[location_id.to_s] = get_facebook_object_json(location_uuid)["location"]
      end

      def get_facebook_object_json(facebook_object_uuid)
        @@FB_OBJ_LOOKUPS.fetch(facebook_object_uuid) || @@FB_OBJ_LOOKUPS[facebook_object_uuuid] = ::JSON.parse(_app_api_client.get("/#{facebook_object_uuid}/"))["data"]
      end
    end

    def initialize(given_access_token)
      access_token = given_access_token
      conn_options = {
        url: "https://graph.facebook.com",  
        params:  {access_token: access_token},
      }
      super(conn_options)
    end

   def friends
      ::JSON.parse(_get_friends_json.body)["data"]
    end

    def friends_close_to_location(center,radius = 50000)
      friends_json = get("/me/friends?fields=third_party_id,location,name&center=#{center}&distance=#{radius}").body
      ::JSON.parse(freinds_json)["data"] 
      binding.pry

      #locations = friends.collect {|f| f['location']}.unique

      #friends_grouped_by_location = friends.group_by {|f| f['location'].try(:[], 'name')}
      #locations = friends.grouped_by_location.keys
      #locations_with_coordinates = locations.inject({}) do |result, location|
      #  result[location.to_s] = coordinates_for_location_id
      #end
    end

    protected
    def _get_friends_json
      get %{/me/friends?fields=third_party_id,location,name}
    end
  end
end

