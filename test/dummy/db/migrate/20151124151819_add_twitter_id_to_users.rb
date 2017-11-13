class AddTwitterIdToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :twitter_id, :integer
    add_index :users, :twitter_id
  end
end
