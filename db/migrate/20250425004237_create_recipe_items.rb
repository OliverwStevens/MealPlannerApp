class CreateRecipeItems < ActiveRecord::Migration[8.0]
  def change
    create_table :recipe_items do |t|
      t.references :recipe, null: false, foreign_key: true
      t.string :name
      t.string :amount

      t.timestamps
    end
  end
end
