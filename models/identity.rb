class Identity
  include DataMapper::Resource
  
  property :uid, Serial
  property :provider, String, :length => 64 
  property :provider_uid, String, :length => 32
  property :access_token, String, :length => 1024  # yes, this is arbitrary - without it defined it defaults to 50
  timestamps :at


  belongs_to :user

  def self.find_with_omniauth(auth)
    first(provider: auth['provider'], uid: auth['uid'])
  end

  def self.create_with_omniauth(auth)
    create(uid: auth['uid'], provider: auth['provider'], access_token: auth['credentials']['token'])
  end
end
