class AddOwnerToAccounts < ActiveRecord::Migration
  def change
    change_table :accounts do |t|
      t.references :owner, polymorphic: true, index: true
    end
  end
end
