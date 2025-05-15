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

  def self.subtract_hashes(hash1, hash2)
    result = {}

    # Process each key in hash1
    hash1.each do |key, value1|
      if hash2.has_key?(key)
        value2 = hash2[key]

        # Extract amounts and units
        amount1, unit1 = parse_amount_and_unit(value1)
        amount2, unit2 = parse_amount_and_unit(value2)

        # Handle non-convertible units (packages, etc.)
        if unit1 && NON_CONVERTIBLE_UNITS.include?(unit1.downcase)
          if unit1.downcase == unit2&.downcase || (unit1.downcase == "package" && unit2&.downcase == "packages") ||
             (unit1.downcase == "packages" && unit2&.downcase == "package")
            # Normalize unit names for singular/plural consistency
            normalized_unit = unit1.downcase.end_with?("s") ? unit1 : unit1 + "s"
            normalized_unit = normalized_unit[0].upcase + normalized_unit[1..-1] if unit1[0] =~ /[A-Z]/

            diff = amount2 - amount1
            if diff != 0
              # Use singular form for 1, plural for others
              final_unit = diff == 1 ? normalized_unit.chomp("s") : normalized_unit
              result[key] = "#{diff.to_i == diff ? diff.to_i : diff} #{final_unit}"
            end
          else
            # If units don't match, just use the values as is
            result[key] = "#{value2} - #{value1}"
          end
        # Handle weight
        elsif unit1 && WEIGHT_CONVERSIONS.key?(unit1.downcase) &&
              unit2 && WEIGHT_CONVERSIONS.key?(unit2.downcase)
          weight1 = amount1 * WEIGHT_CONVERSIONS[unit1.downcase]
          weight2 = amount2 * WEIGHT_CONVERSIONS[unit2.downcase]
          diff = weight2 - weight1
          if diff != 0
            result[key] = "#{diff.round(2)} g"
          end
        # Handle volume
        elsif unit1 && VOLUME_CONVERSIONS.key?(unit1.downcase) &&
              unit2 && VOLUME_CONVERSIONS.key?(unit2.downcase)
          volume1 = amount1 * VOLUME_CONVERSIONS[unit1.downcase]
          volume2 = amount2 * VOLUME_CONVERSIONS[unit2.downcase]
          diff = volume2 - volume1
          if diff != 0
            result[key] = "#{diff.round(2)} ml"
          end
        else
          # For anything else, just use string representation
          result[key] = "#{value2} - #{value1}"
        end
      end
    end

    # Add keys that are only in hash2
    hash2.each do |key, value|
      unless hash1.has_key?(key)
        result[key] = value
      end
    end

    result
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
