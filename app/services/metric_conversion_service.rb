class MetricConversionService
  # Constants for unit conversions
  WEIGHT_CONVERSIONS = {
    # to grams
    "g" => 1,
    "gram" => 1,
    "grams" => 1,
    "oz" => 28.35,
    "ounce" => 28.35,
    "ounces" => 28.35,
    "lb" => 453.592,
    "lbs" => 453.592,
    "pound" => 453.592,
    "pounds" => 453.592
  }

  VOLUME_CONVERSIONS = {
    # to milliliters
    "ml" => 1,
    "milliliter" => 1,
    "milliliters" => 1,
    "l" => 1000,
    "liter" => 1000,
    "liters" => 1000,
    "fl oz" => 29.574,
    "fluid ounce" => 29.574,
    "fluid ounces" => 29.574,
    "cup" => 236.588,
    "cups" => 236.588,
    "tablespoon" => 14.787,
    "tablespoons" => 14.787,
    "tbsp" => 14.787,
    "teaspoon" => 4.929,
    "teaspoons" => 4.929,
    "tsp" => 4.929,
    "pint" => 473.176,
    "pints" => 473.176,
    "pt" => 473.176,
    "quart" => 946.353,
    "quarts" => 946.353,
    "qt" => 946.353,
    "gallon" => 3785.41,
    "gallons" => 3785.41,
    "gal" => 3785.41,
    "drop" => 0.05,
    "drops" => 0.05
  }

  # Units that don't have a simple conversion to metric
  NON_CONVERTIBLE_UNITS = %w[
  sprig sprigs clove cloves piece pieces
  slice slices can cans jar jars package packages bag bags
  box boxes bunch bunches leaf leaves stick sticks bar bars
  square squares handful handfuls
  pinch pinches dash dashes smidgen smidgens
]


  def self.convert_to_metric(items_array)
    items_array.map do |item_hash|
      item_name, amount_with_unit = item_hash.first

      # Extract numeric value and unit from the string
      amount, unit = parse_amount_and_unit(amount_with_unit)

      # Don't try to convert if there's no unit or it's non-convertible
      if unit.nil? || NON_CONVERTIBLE_UNITS.include?(unit.downcase)
        # Return original format
        { item_name => amount_with_unit }
      elsif WEIGHT_CONVERSIONS.key?(unit.downcase)
        # Convert to grams
        converted_amount = amount * WEIGHT_CONVERSIONS[unit.downcase]
        { item_name => "#{converted_amount.round(2)} g" }
      elsif VOLUME_CONVERSIONS.key?(unit.downcase)
        # Convert to milliliters
        converted_amount = amount * VOLUME_CONVERSIONS[unit.downcase]
        { item_name => "#{converted_amount.round(2)} ml" }
      else
        # For unknown units, return as is
        { item_name => amount_with_unit }
      end
    end
  end

  private

  def self.parse_amount_and_unit(amount_with_unit)
    # Convert to string to ensure we can process it
    amount_with_unit = amount_with_unit.to_s

    # Regular expression to extract the number and unit
    match = amount_with_unit.match(/^([\d.]+)\s*(.+)$/)

    if match
      amount = match[1].to_f
      unit = match[2].strip
      [ amount, unit ]
    else
      [ amount_with_unit, nil ]
    end
  end
end

# Example usage:
# items = [
#   { water: "6 ml" },
#   { Oranges: "3 oz" },
#   { Sugar: "2 cups" },
#   { Chocolate: "1 package" },
#   { mint: "6 sprigs" },
#   { Milk: "8 gallons" }
# ]
#
# result = MetricConversionService.convert_to_metric(items)
# puts result.inspect
# => [{:water=>"6.0 ml"}, {:Oranges=>"85.05 g"}, {:Sugar=>"480.0 g"}, {:Chocolate=>"1 package"}, {:mint=>"6 sprigs"}, {:Milk=>"30283.28 ml"}]
