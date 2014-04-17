class CreateUsersAndIdentities < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.timestamps
    end
    
    create_table :identities do |t|
      t.string :uid
      t.string :provider
      t.string :access_token
      t.references :user
    end

    add_index :identities, :user_id
  end
end
