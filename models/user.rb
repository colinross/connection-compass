class User
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String
  timestamps :at

  has n, :identities, :constraint => :destroy

  def self.create_with_omniauth(info)
    create(name: info['name'])
  end
end
