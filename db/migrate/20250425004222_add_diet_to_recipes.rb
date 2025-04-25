class AddDietToRecipes < ActiveRecord::Migration[8.0]
  def change
    add_column :recipes, :diet, :string
  end
end
