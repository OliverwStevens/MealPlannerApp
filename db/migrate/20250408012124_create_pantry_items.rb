class CreatePantryItems < ActiveRecord::Migration[8.0]
  def change
    create_table :pantry_items do |t|
      t.string :name
      t.string :barcode
      t.integer :quantity
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
