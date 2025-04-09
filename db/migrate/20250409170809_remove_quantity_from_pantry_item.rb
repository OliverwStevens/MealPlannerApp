class RemoveQuantityFromPantryItem < ActiveRecord::Migration[8.0]
  def change
    remove_column :pantry_items, :quantity, :integer
  end
end
