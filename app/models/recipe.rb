class Recipe < ApplicationRecord
  belongs_to :user

  has_many :recipe_items, dependent: :destroy

  accepts_nested_attributes_for :recipe_items,
                               allow_destroy: true,
                               reject_if: :all_blank

  enum :recipe_type, { main: 0, side: 1, dessert: 2, appetizer: 3, snack: 4, breakfast: 5, beverage: 6 }
end
