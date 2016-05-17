include MigrationDatabaseHelper

class DeviseTokenAuthCreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.references :account, index: true, foreign_key: true
      t.string :other_field

      t.timestamps null: false
    end
  end
end
