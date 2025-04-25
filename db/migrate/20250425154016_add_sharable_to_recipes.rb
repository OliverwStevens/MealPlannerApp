class AddSharableToRecipes < ActiveRecord::Migration[8.0]
  def change
    add_column :recipes, :sharable, :boolean
  end
end
