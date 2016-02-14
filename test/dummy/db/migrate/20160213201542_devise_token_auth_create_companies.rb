include MigrationDatabaseHelper

class DeviseTokenAuthCreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :other_field

      t.timestamps null: false
    end
  end
end
