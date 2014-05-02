class Profile
  include DataMapper::Resource
  
  property :id, Serial
  
  property :location_lat, String
  property :location_long, String
  property :location_name, String
  
  property :profile_url, String, length: 255
  property :profile_image_url, String, length: 255

  belongs_to :user

  timestamps :at

  before :create, :geolocate_location
  before :update, :geolocate_location

  def geolocate_location
    location = ::Services::Facebook.coordinates_for_location_id ["location"]
    self.coordinates_lat = location['latitude']
    self.coordinates_long = location['longitude']
  end

  def self.create_from_facebook_auth_info(info)
    create({location_lat:nil, location_long: nil, location_name: info['location'], profile_url: info['urls']['Facebook'], profile_image_url: info['image']})
  end
end
