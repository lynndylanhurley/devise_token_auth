class AddOperatingThetanToUser < ActiveRecord::Migration
  def change
    add_column :users, :operating_thetan, :integer
  end
end
