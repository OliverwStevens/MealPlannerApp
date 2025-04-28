class CreateMealRecipes < ActiveRecord::Migration[7.0]
  def change
    create_table :meal_recipes do |t|
      t.references :meal, null: false, foreign_key: true
      t.references :recipe, null: false, foreign_key: true
      t.integer :position
      t.text :notes

      t.timestamps
    end

    add_index :meal_recipes, [ :meal_id, :recipe_id ], unique: true
  end
end
