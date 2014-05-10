require_relative 'base'

module Services
  class Facebook < Base
    class FacebookError < RuntimeError; end
    class InvalidAuthToken < FacebookError; end
    class ApplicationNotAuthorized < InvalidAuthToken; end
    
    # Not directly needed now, but eventualy we should sign all our fb requests with the hash of these,
    # see https://developers.facebook.com/docs/graph-api/securing-requests/

    attr_accessor :access_token

    # CLASS Methods
    class <<self 
      def _app_api_client
        @@app_api_client ||= new(::ConnectionCompass.settings.services["facebook"]["app_access_token"])
      end
      def fb_object_cache_store
        @@fb_object_cache_store ||= Moneta.new(:DataMapper, setup: ConnectionCompass::DATABASE_URL, table: :fb_object_cache)
      end
      def verify_access_token!
        response = _app_api_client.get '/debug_token' do |req|
          req.params[:input_token] = access_token
        end
        response.body["data"]["is_valid"]
      end
      def get_facebook_object(facebook_object_uuid)
        fb_object_cache_store[facebook_object_uuid] ||= _app_api_client.get("/#{facebook_object_uuid}/").body
      end
    end

    def initialize(given_access_token)
      access_token = given_access_token
      conn_options = {
        url: "https://graph.facebook.com/",  
        params:  {access_token: access_token},
      }
      super(conn_options)
    end
    def has_permission_to?(permission_key)
      @permissions ||= get("/v1.0//me/permissions").body["data"]
      found_permission = @permissions.find {|permission|  permission["permission"] == permission_key && permission["status"] == "granted" }
      !found_permission.nil?
    end
    def handle_error_response(error)
      case error["code"]
      when 190
        if error["error_subcode"] == 458
          raise ApplicationNotAuthorized
        end
      end
    end

    def friends_by_location(center = [], distance = 30)
      @friends ||= get("/v1.0/me/friends?fields=third_party_id,location,name,link,picture").body["data"]
      @friends_with_locations = @friends.reject {|f| f['location'].nil?}
      @friends_unique_locations = @friends_with_locations.collect {|f| f['location']['id']}.uniq
      
      # this would be a good place to cache all location data for at least a couple days since location info is not specific to a user/friend.
      @friends_location_info = @friends_unique_locations.inject({}) do |result, location_uuid|
        result[location_uuid] = self.class.get_facebook_object(location_uuid)
        result
      end

      unless center.empty?
        @center = Geokit::LatLng.new(*center)
        @location_distance_from_center = @friends_location_info.inject({}) do |result, location|
          loc_coords = Geokit::LatLng.new(*location.last['location'].values)
          result[location.first] = @center.distance_to(loc_coords)
          result
        end
        locations_in_range = @location_distance_from_center.reject {|location, distance_from_center| distance_from_center > distance}
        @friends_in_range = @friends.keep_if {|friend| locations_in_range.include? friend.try(:[],'location').try(:[],'id')}
      end
      (@friends_in_range||@friends_with_locations).group_by {|friend| friend['location']['name'] }
    end

  end
end

