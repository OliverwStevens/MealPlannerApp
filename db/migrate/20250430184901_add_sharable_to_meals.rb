class AddSharableToMeals < ActiveRecord::Migration[8.0]
  def change
    add_column :meals, :sharable, :boolean
  end
end
