class Identity
  include DataMapper::Resource
  
  property :uid, Serial
  property :provider, String, :length => 64 
  property :provider_uid, String, :length => 32
  property :access_token, String, :length => 1024  # yes, this is arbitrary - without it defined it defaults to 50
  timestamps :at


  belongs_to :user

  def self.find_and_update_or_create_with_omniauth(auth, user)
    if existing_identity = find_with_omniauth(auth)
      existing_identity.update(user: user, access_token: auth["credentials"]['token'])
    else
      identity = create_with_omniauth(auth, user)
    end
    existing_identity || identity
  end

  def self.find_with_omniauth(auth)
    first(provider: auth['provider'], provider_uid: auth['uid'])
  end

  def self.create_with_omniauth(auth, user)
    create(provider: auth['provider'], provider_uid: auth['uid'], access_token: auth['credentials']['token'], user: user)
  end
end
