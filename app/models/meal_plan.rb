# app/models/meal_plan.rb
class MealPlan < ApplicationRecord
  belongs_to :user
  belongs_to :meal

  validates :date, presence: true
  validates_uniqueness_of :date, scope: [ :user_id, :meal_id ],
    message: "already has this meal assigned"
end
