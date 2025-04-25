class CreateRecipes < ActiveRecord::Migration[8.0]
  def change
    create_table :recipes do |t|
      t.string :name
      t.text :procedure
      t.integer :servings
      t.integer :difficulty
      t.string :prep_time

      t.timestamps
    end
  end
end
