class User < ActiveRecord::Base
  has_many :identities

  def self.create_with_omniauth(info)
    create(name: info['name'])
  end
end