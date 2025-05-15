class MetricConversionService
  WEIGHT_CONVERSIONS = {
    "g" => 1, "gram" => 1, "grams" => 1,
    "oz" => 28.35, "ounce" => 28.35, "ounces" => 28.35,
    "lb" => 453.592, "lbs" => 453.592, "pound" => 453.592, "pounds" => 453.592
  }

  VOLUME_CONVERSIONS = {
    "ml" => 1, "milliliter" => 1, "milliliters" => 1,
    "l" => 1000, "liter" => 1000, "liters" => 1000,
    "fl oz" => 29.574, "fluid ounce" => 29.574, "fluid ounces" => 29.574,
    "cup" => 236.588, "cups" => 236.588,
    "tablespoon" => 14.787, "tablespoons" => 14.787, "tbsp" => 14.787,
    "teaspoon" => 4.929, "teaspoons" => 4.929, "tsp" => 4.929,
    "pint" => 473.176, "pints" => 473.176, "pt" => 473.176,
    "quart" => 946.353, "quarts" => 946.353, "qt" => 946.353,
    "gallon" => 3785.41, "gallons" => 3785.41, "gal" => 3785.41,
    "drop" => 0.05, "drops" => 0.05
  }

  NON_CONVERTIBLE_UNITS = %w[
    sprig sprigs clove cloves piece pieces slice slices can cans jar jars
    package packages bag bags box boxes bunch bunches leaf leaves stick sticks
    bar bars square squares handful handfuls pinch pinches dash dashes smidgen smidgens
  ]

  def self.convert_hash_to_metric(items_hash)
    items_hash.each_with_object({}) do |(item, values), result|
      values = Array(values)
      total_weight = 0.0
      total_volume = 0.0
      non_convertibles = []

      values.each do |value|
        amount, unit = parse_amount_and_unit(value)

        if unit.nil? || NON_CONVERTIBLE_UNITS.include?(unit.downcase)
          non_convertibles << value
        elsif WEIGHT_CONVERSIONS.key?(unit.downcase)
          total_weight += amount * WEIGHT_CONVERSIONS[unit.downcase]
        elsif VOLUME_CONVERSIONS.key?(unit.downcase)
          total_volume += amount * VOLUME_CONVERSIONS[unit.downcase]
        else
          non_convertibles << value
        end
      end

      result[item] =
        if total_weight > 0
          val = "#{total_weight.round(2)} g"
          non_convertibles.empty? ? val : [ val ] + non_convertibles
        elsif total_volume > 0
          val = "#{total_volume.round(2)} ml"
          non_convertibles.empty? ? val : [ val ] + non_convertibles
        else
          non_convertibles.length == 1 ? non_convertibles.first : non_convertibles
        end
    end
  end

  private

  def self.parse_amount_and_unit(str)
    str = str.to_s.strip
    match = str.match(/^([\d.]+)\s*(.+)?$/)
    if match
      [ match[1].to_f, match[2]&.strip ]
    else
      [ str, nil ]
    end
  end
end
