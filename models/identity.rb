class Identity
  include DataMapper::Resource
  
  property :id, Serial
  property :provider, String, :length => 1024  # yes, this is arbitrary - without it defined it defaults to 50
  property :access_token, String
  timestamps :at


  belongs_to :user

  def self.find_with_omniauth(auth)
    find_by provider: auth['provider'], uid: auth['uid']
  end

  def self.create_with_omniauth(auth)
    create(uid: auth['uid'], provider: auth['provider'])
  end
end
