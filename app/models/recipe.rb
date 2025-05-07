class Recipe < ApplicationRecord
  belongs_to :user
  has_one_attached :image
  has_many :meal_recipes, dependent: :destroy
  has_many :meals, through: :meal_recipes
  scope :sharable, -> { where(sharable: true) }


  has_many :recipe_items, dependent: :destroy

  accepts_nested_attributes_for :recipe_items,
                               allow_destroy: true,
                               reject_if: :all_blank

  enum :recipe_type, { main: 0, side: 1, dessert: 2, appetizer: 3, snack: 4, breakfast: 5, beverage: 6 }


  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :procedure, presence: true, length: { minimum: 10, maximum: 5000 }
  validates :servings, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :difficulty, presence: true, numericality: { only_integer: true, greater_than: 0, less_than: 11 }
  # validates :prep_time, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :recipe_type, presence: true
  validates :diet, presence: true
  # For the boolean field
  validates :sharable, inclusion: { in: [ true, false ] }

  # If you want to validate the image (assuming you're using Active Storage)
  # validates :image, presence: true, if: -> { image.attached? }

  # Validate nested recipe_items
  validates :recipe_items, presence: true

  max_paginates_per 2

  before_create :generate_uuid

  private

  def generate_uuid
    self.recipe_uuid ||= SecureRandom.uuid
  end
end
