class AddTypeToRecipes < ActiveRecord::Migration[8.0]
  def change
    add_column :recipes, :recipe_type, :integer
  end
end
