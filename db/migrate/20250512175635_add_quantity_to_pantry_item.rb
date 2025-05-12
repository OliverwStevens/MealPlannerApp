class AddQuantityToPantryItem < ActiveRecord::Migration[8.0]
  def change
    add_column :pantry_items, :quantity, :string
  end
end
