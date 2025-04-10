class AddImgUrLToPantryItem < ActiveRecord::Migration[8.0]
  def change
    add_column :pantry_items, :img_url, :string
  end
end
