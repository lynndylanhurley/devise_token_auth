include MigrationDatabaseHelper

class DeviseTokenAuthCreateMultiAuthUsers < ActiveRecord::Migration
  # This was largely copied from DeviseTokenAuthCreateUsers

  def change
    create_table :multi_auth_users do |t|
      ## Database authenticatable
      t.string :email
      t.string :encrypted_password, :null => false, :default => ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      t.string   :reset_password_redirect_url

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, :default => 0, :null => false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :confirm_success_url
      t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, :default => 0, :null => false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      ## User Info
      t.string :name
      t.string :nickname
      t.string :image

      ## Identifiers used for allowing users to authenticate multiple ways
      t.integer :twitter_id
      t.integer :facebook_user_id

      ## Tokens
      if json_supported_database?
        t.json :tokens
      else
        t.text :tokens
      end

      t.timestamps
    end

    add_index :multi_auth_users, :email
    add_index :multi_auth_users, :reset_password_token, :unique => true
    add_index :multi_auth_users, :confirmation_token,   :unique => true
    add_index :multi_auth_users, :nickname,             :unique => true
    add_index :multi_auth_users, :twitter_id,           :unique => true
    add_index :multi_auth_users, :facebook_user_id,     :unique => true
  end
end
