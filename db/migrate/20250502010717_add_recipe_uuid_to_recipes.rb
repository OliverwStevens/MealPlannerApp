class AddRecipeUuidToRecipes < ActiveRecord::Migration[8.0]
  def change
    add_column :recipes, :recipe_uuid, :string
    add_index :recipes, :recipe_uuid
  end
end
