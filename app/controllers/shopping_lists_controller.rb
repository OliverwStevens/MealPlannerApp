class ShoppingListsController < ApplicationController
  before_action :authenticate_user!

  def index
    # Get date range from params or default to current week
    @start_date = params[:start_date] ? Date.parse(params[:start_date]) : Date.current.beginning_of_week
    @end_date = @start_date.end_of_week

    # Load meal plans for the selected date range
    @meal_plans = current_user.meal_plans
                    .includes(meal: { recipes: :recipe_items })
                    .where(date: @start_date..@end_date)

    # Group meal plans by date
    @meal_plans_by_date = @meal_plans.group_by(&:date)

    # Collect all recipe items across all meals in the meal plan
    @all_recipe_items = []
    @meal_plans.each do |meal_plan|
      meal_plan.meal.recipes.each do |recipe|
        recipe.recipe_items.each do |item|
          @all_recipe_items << item
        end
      end
    end

    # Process and aggregate ingredients
    @aggregated_ingredients = aggregate_ingredients(@all_recipe_items)
  end

  private

  def aggregate_ingredients(recipe_items)
    # Group by normalized ingredient name
    ingredients_by_name = {}

    recipe_items.each do |item|
      # Normalize the ingredient name (lowercase, trim)
      name = item.name.downcase.strip

      # Initialize if this is the first time seeing this ingredient
      ingredients_by_name[name] ||= []
      ingredients_by_name[name] << item
    end

    # Process each ingredient group to combine quantities
    aggregated_results = {}

    ingredients_by_name.each do |name, items|
      # Group items by their unit type
      by_unit = {}

      items.each do |item|
        # Parse the amount string to extract value and unit
        amount_info = parse_amount(item.amount)
        next unless amount_info # Skip if parsing failed

        unit = amount_info[:unit]
        value = amount_info[:value]

        # Initialize this unit group if needed
        by_unit[unit] ||= {
          total: 0,
          items: [],
          original_unit: unit # Keep track of the original unit format
        }

        # Add to the total
        by_unit[unit][:total] += value
        by_unit[unit][:items] << item
      end

      # Store the aggregated result
      aggregated_results[name] = by_unit
    end

    # Convert the results to a more usable format and perform unit conversions
    finalize_aggregation(aggregated_results)
  end

  def parse_amount(amount_str)
    # Handle ranges like "1 to 2 cups" by taking the upper value
    if amount_str =~ /(\d*\.?\d+)\s*to\s*(\d*\.?\d+)\s*(.*)/i
      value = $2.to_f  # Use the upper bound of the range
      unit = $3.strip.downcase
    else
      # Regular case like "2 cups"
      amount_str =~ /(\d*\.?\d+)\s*(.*)/i
      return nil unless $1 # Return nil if no number found

      value = $1.to_f
      unit = $2.strip.downcase
    end

    # Normalize units
    normalized_unit = normalize_unit(unit)

    { value: value, unit: normalized_unit, original_format: unit }
  end

  def normalize_unit(unit)
    # Remove trailing 's' for plurals
    singular = unit.end_with?("s") && !unit.end_with?("ss") ? unit.chop : unit

    # Map of unit normalizations
    unit_map = {
      # Weight units
      "g" => "g", "gram" => "g", "grams" => "g",
      "kg" => "kg", "kilogram" => "kg", "kilograms" => "kg",
      "oz" => "oz", "ounce" => "oz", "ounces" => "oz",
      "lb" => "lb", "lbs" => "lb", "pound" => "lb", "pounds" => "lb",

      # Volume units
      "ml" => "ml", "milliliter" => "ml", "milliliters" => "ml",
      "l" => "l", "liter" => "l", "liters" => "l",
      "tsp" => "tsp", "teaspoon" => "tsp", "teaspoons" => "tsp",
      "tbsp" => "tbsp", "tablespoon" => "tbsp", "tablespoons" => "tbsp",
      "cup" => "cup", "cups" => "cup",
      "pt" => "pt", "pint" => "pt", "pints" => "pt",
      "qt" => "qt", "quart" => "qt", "quarts" => "qt",
      "gal" => "gal", "gallon" => "gal", "gallons" => "gal",
      "fl oz" => "fl oz", "fluid ounce" => "fl oz", "fluid ounces" => "fl oz",

      # Count units - these generally don't convert between each other
      "piece" => "piece", "pieces" => "piece",
      "slice" => "slice", "slices" => "slice",
      "clove" => "clove", "cloves" => "clove",
      "pinch" => "pinch", "pinches" => "pinch",
      "dash" => "dash", "dashes" => "dash",
      "sprig" => "sprig", "sprigs" => "sprig",
      "leaf" => "leaf", "leaves" => "leaf",
      "stick" => "stick", "sticks" => "stick",
      "can" => "can", "cans" => "can",
      "jar" => "jar", "jars" => "jar",
      "package" => "package", "packages" => "package",
      "bag" => "bag", "bags" => "bag",
      "box" => "box", "boxes" => "box",
      "bunch" => "bunch", "bunches" => "bunch",
      "handful" => "handful", "handfuls" => "handful",
      "drop" => "drop", "drops" => "drop",
      "bar" => "bar", "bars" => "bar",
      "square" => "square", "squares" => "square",
      "smidgen" => "smidgen", "smidgens" => "smidgen"
    }

    # Return the normalized unit or the original if not found
    unit_map[singular] || unit
  end

  def finalize_aggregation(aggregated_results)
    final_results = {}

    aggregated_results.each do |ingredient_name, unit_groups|
      # Try to convert and combine where possible
      converted_units = convert_and_combine_units(unit_groups)

      # Format the final strings
      formatted_amounts = []

      converted_units.each do |unit, data|
        # Format the number (handle whole numbers vs. decimals)
        value = data[:total]

        if value == value.to_i
          formatted_value = value.to_i.to_s
        else
          # Round to 2 decimal places for cleaner display
          formatted_value = value.round(2).to_s
        end

        # Use the original unit format for display (singular/plural)
        display_unit = format_unit_for_display(unit, value)

        formatted_amounts << "#{formatted_value} #{display_unit}"
      end

      final_results[ingredient_name] = formatted_amounts
    end

    final_results
  end

  def convert_and_combine_units(unit_groups)
    result = {}

    # First pass: Process volume units that can be converted
    volume_conversions = {
      "tsp" => { "tbsp" => 1/3.0, "cup" => 1/48.0, "ml" => 4.93 },
      "tbsp" => { "tsp" => 3.0, "cup" => 1/16.0, "ml" => 14.79 },
      "cup" => { "tsp" => 48.0, "tbsp" => 16.0, "ml" => 236.59, "pt" => 0.5 },
      "ml" => { "l" => 0.001, "tsp" => 0.2, "tbsp" => 0.07 },
      "l" => { "ml" => 1000.0 },
      "fl oz" => { "cup" => 0.125, "ml" => 29.57 },
      "pt" => { "cup" => 2.0, "qt" => 0.5 },
      "qt" => { "pt" => 2.0, "gal" => 0.25 },
      "gal" => { "qt" => 4.0 }
    }

    # Weight conversions
    weight_conversions = {
      "g" => { "kg" => 0.001, "oz" => 0.035 },
      "kg" => { "g" => 1000.0, "lb" => 2.20462 },
      "oz" => { "g" => 28.35, "lb" => 0.0625 },
      "lb" => { "oz" => 16.0, "kg" => 0.453592 }
    }

    # Decide primary unit for each category
    volume_units = [ "cup", "tbsp", "tsp", "ml", "l", "fl oz", "pt", "qt", "gal" ]
    weight_units = [ "g", "kg", "oz", "lb" ]

    # Handle volume conversions
    volume_items = {}
    weight_items = {}
    other_items = {}

    unit_groups.each do |unit, data|
      if volume_units.include?(unit)
        # Store in volume group
        volume_items[unit] = data
      elsif weight_units.include?(unit)
        # Store in weight group
        weight_items[unit] = data
      else
        # Can't convert, keep as is
        other_items[unit] = data
      end
    end

    # Process volume conversions if we have multiple volume units
    if volume_items.size > 1
      # Choose a target unit (cups is usually a good choice for recipes)
      target_unit = volume_items.keys.include?("cup") ? "cup" : volume_items.keys.first

      total_in_target = 0

      volume_items.each do |unit, data|
        if unit == target_unit
          total_in_target += data[:total]
        else
          # Convert to target unit if possible
          conversion_path = find_conversion_path(unit, target_unit, volume_conversions)
          if conversion_path
            converted_value = convert_through_path(data[:total], conversion_path, volume_conversions)
            total_in_target += converted_value
          else
            # Can't convert, keep separate
            result[unit] = data
          end
        end
      end

      # Add the combined total
      if total_in_target > 0
        result[target_unit] = { total: total_in_target, original_unit: target_unit }
      end
    else
      # Just one volume unit or none, add as is
      result.merge!(volume_items)
    end

    # Process weight conversions similarly
    if weight_items.size > 1
      # Choose a target unit
      target_unit = weight_items.keys.include?("g") ? "g" : weight_items.keys.first

      total_in_target = 0

      weight_items.each do |unit, data|
        if unit == target_unit
          total_in_target += data[:total]
        else
          # Convert to target unit if possible
          conversion_path = find_conversion_path(unit, target_unit, weight_conversions)
          if conversion_path
            converted_value = convert_through_path(data[:total], conversion_path, weight_conversions)
            total_in_target += converted_value
          else
            # Can't convert, keep separate
            result[unit] = data
          end
        end
      end

      # Add the combined total
      if total_in_target > 0
        result[target_unit] = { total: total_in_target, original_unit: target_unit }
      end
    else
      # Just one weight unit or none, add as is
      result.merge!(weight_items)
    end

    # Add all other non-convertible units
    result.merge!(other_items)

    result
  end

  def find_conversion_path(from_unit, to_unit, conversion_map)
    # Direct conversion
    return [ from_unit, to_unit ] if conversion_map[from_unit] && conversion_map[from_unit][to_unit]

    # Try one level of indirection
    conversion_map[from_unit]&.each_key do |intermediate|
      if conversion_map[intermediate] && conversion_map[intermediate][to_unit]
        return [ from_unit, intermediate, to_unit ]
      end
    end

    nil  # No conversion path found
  end

  def convert_through_path(value, path, conversion_map)
    result = value

    (0...(path.size - 1)).each do |i|
      from = path[i]
      to = path[i + 1]
      result *= conversion_map[from][to]
    end

    result
  end

  def format_unit_for_display(unit, value)
    # Pluralize units if value is not 1
    if value == 1
      unit
    else
      # Handle special pluralization cases
      case unit
      when "leaf"
        "leaves"
      when "dash"
        "dashes"
      when "box"
        "boxes"
      when "bunch"
        "bunches"
      else
        # Default pluralization by adding 's'
        "#{unit}s"
      end
    end
  end
end
