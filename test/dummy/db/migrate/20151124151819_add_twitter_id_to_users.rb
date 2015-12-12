class AddTwitterIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :twitter_id, :integer
    add_index :users, :twitter_id
  end
end
