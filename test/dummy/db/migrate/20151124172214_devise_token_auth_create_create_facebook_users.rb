class DeviseTokenAuthCreateCreateFacebookUsers < ActiveRecord::Migration
  def change
    create_table :facebook_users do |t|
      t.integer :facebook_id
    end

    add_index :facebook_users, :facebook_id
  end
end
