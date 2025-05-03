class Meal < ApplicationRecord
  belongs_to :user
  has_one_attached :image
  has_many :meal_recipes, dependent: :destroy
  has_many :recipes, through: :meal_recipes
  scope :sharable, -> { where(sharable: true) }


  enum :meal_type, { breakfast: 0, lunch: 1, dinner: 2 }


  validates :name, presence: true
  validates :description, presence: true
  validates :meal_type, presence: true
  validates :sharable, inclusion: { in: [ true, false ] }
  # This ensures recipes exist but doesn't require them
  def recipes=(new_recipes)
    super(Array(new_recipes).reject(&:blank?))
  end
end
