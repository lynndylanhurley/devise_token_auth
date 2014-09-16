class AddFavoriteColorToMangs < ActiveRecord::Migration
  def change
    add_column :mangs, :favorite_color, :string
  end
end
