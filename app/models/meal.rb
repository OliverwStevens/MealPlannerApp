class Meal < ApplicationRecord
  belongs_to :user
  has_many :meal_recipes, dependent: :destroy
  has_many :recipes, through: :meal_recipes

  validates :name, presence: true
  validates :description, presence: true

  # This ensures recipes exist but doesn't require them
  def recipes=(new_recipes)
    super(Array(new_recipes).reject(&:blank?))
  end
end
