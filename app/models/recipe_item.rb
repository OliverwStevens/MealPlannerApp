class RecipeItem < ApplicationRecord
  belongs_to :recipe

  # Case-insensitive units (e.g., "G", "g", "Gram", "GRAM")
  UNITS = %w[
    g gram grams gal l lb lbs pound pounds ounce ounces oz cup cups
    tablespoon tablespoons tbsp teaspoon teaspoons tsp
    milliliter milliliters ml liter liters l
    pinch pinches dash dashes fl\ oz fluid\ ounce fluid\ ounces
    pint pints pt quart quarts qt gallon gallons drop drops
    smidgen smidgens sprig sprigs clove cloves piece pieces
    slice slices can cans jar jars package packages bag bags
    box boxes bunch bunches leaf leaves stick sticks bar bars
    square squares dash dashes handful handfuls
  ].freeze

  validates :name, presence: true, length: { minimum: 2, maximum: 200 }
  validates :amount,
    presence: true,
    length: { minimum: 1, maximum: 50 },
    format: {
      with: /\A\d*\.?\d+\s*(?:to\s*\d*\.?\d+\s*)?(?:#{UNITS.join('|')})\z/i,
      message: "must be like '1 cup', '2.5 lbs', or '500 mL'"
    }

    def amount_value
      amount
    end
end
