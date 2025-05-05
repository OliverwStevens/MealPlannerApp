class CreateMealPlans < ActiveRecord::Migration[8.0]
  def change
    create_table :meal_plans do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date
      t.references :meal, null: false, foreign_key: true

      t.timestamps
    end
  end
end
