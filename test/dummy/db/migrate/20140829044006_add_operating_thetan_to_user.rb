class AddOperatingThetanToUser < ActiveRecord::Migration
  def change
    add_column :users, :operating_thetan, :integer
    add_column :users, :favorite_color, :string
  end
end
