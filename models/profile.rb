class Profile
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String
  property :location_lat, String
  property :location_long, String
  property :location_name, String
  
  property :profile_url, String, length: 255
  property :profile_image_url, String, length: 255

  belongs_to :user

  timestamps :at

  def self.create_or_update_from_facebook_auth_info(user,info)
    location = ::Services::Facebook.get_facebook_object(info['extra']['raw_info']['location']['id'])
    if user.profile.nil?
      user.profile = Profile.create(user: user)
    end
    user.profile.update({location_lat:location['location']['latitude'], location_long: location['location']['longitude'], location_name: location['name'],
            profile_url: info['info']['urls']['Facebook'], profile_image_url: info['info']['image'],
            name: info['info']['name']
    })
    return user.profile
  end
end
