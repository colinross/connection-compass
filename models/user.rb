class User
  include DataMapper::Resource
  property :id, Serial
  timestamps :at

  has n, :identities, :constraint => :destroy
  has 1, :profile
end
