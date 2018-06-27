# frozen_string_literal: true

include MigrationDatabaseHelper

class DeviceTokenAuthCreateTenantUsers < ActiveRecord::Migration[5.1]
  def change
    create_table(:tenant_users) do |t|
      ## Required
      t.string :provider, :null => false
      t.string :uid, :null => false, :default => ""

      ## Database authenticatable
      t.string :encrypted_password, :null => false, :default => ""

      ## User Info
      t.string :name
      t.string :nickname
      t.string :image
      t.string :email

      t.string :tenant

      ## Tokens
      if json_supported_database?
        t.json :tokens
      else
        t.text :tokens
      end

      t.timestamps
    end

    add_index :tenant_users, :email
    add_index :tenant_users, [:tenant, :uid, :provider],     :unique => true
  end
end
