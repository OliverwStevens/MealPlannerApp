class RecipesFromPantryService
  def self.pantry_to_recipes(pantry_items_hash, current_user_recipes)
    recipes_to_make = {}

    loop do
      recipe_cost_hash = {}

      current_user_recipes.each do |recipe|
        # Convert recipe items to metric
        recipe_items = {}
        recipe.recipe_items.each do |item|
          recipe_items[item.name.downcase] = item.amount
        end
        processed_recipe_items_hash = MetricConversionService.convert_hash_to_metric(recipe_items)

        # Check if all recipe items are in pantry
        unless processed_recipe_items_hash.keys.all? { |key| pantry_items_hash.key?(key) }
          recipe_cost_hash[recipe.id] = 0
          next
        end

        # Calculate cost based on total ingredient usage
        total_cost = 0
        sufficient = true
        processed_recipe_items_hash.each do |key, value|
          pantry_value = pantry_items_hash[key]
          next unless pantry_value

          # Parse amounts and units using converted values
          recipe_amount, recipe_unit = MetricConversionService.parse_amount_and_unit(value)
          pantry_amount, pantry_unit = MetricConversionService.parse_amount_and_unit(pantry_value)

          # Ensure units are compatible
          if recipe_unit && pantry_unit &&
             (MetricConversionService::WEIGHT_CONVERSIONS.key?(recipe_unit.downcase) &&
              MetricConversionService::WEIGHT_CONVERSIONS.key?(pantry_unit.downcase) ||
              MetricConversionService::VOLUME_CONVERSIONS.key?(recipe_unit.downcase) &&
              MetricConversionService::VOLUME_CONVERSIONS.key?(pantry_unit.downcase))
            # Convert both to common unit (grams or ml)
            recipe_converted = recipe_amount * (MetricConversionService::WEIGHT_CONVERSIONS[recipe_unit.downcase] || MetricConversionService::VOLUME_CONVERSIONS[recipe_unit.downcase])
            pantry_converted = pantry_amount * (MetricConversionService::WEIGHT_CONVERSIONS[pantry_unit.downcase] || MetricConversionService::VOLUME_CONVERSIONS[pantry_unit.downcase])

            cost = pantry_converted / recipe_converted
            if cost < 1
              sufficient = false
              recipe_cost_hash[recipe.id] = 0
              break
            end
            total_cost += recipe_converted
          else
            # Non-convertible units or mismatch
            sufficient = false
            recipe_cost_hash[recipe.id] = 0
            break
          end
        end

        recipe_cost_hash[recipe.id] = sufficient ? total_cost * recipe.servings : 0
      end

      # Break if no valid recipes
      break if recipe_cost_hash.empty? || recipe_cost_hash.values.all? { |value| value == 0 }

      # Select the recipe with the highest cost
      recipe_id, _ = recipe_cost_hash.max_by { |key, value| value }
      recipes_to_make[recipe_id] = (recipes_to_make[recipe_id] || 0) + 1

      # Subtract pantry items
      recipe = current_user_recipes.find { |r| r.id == recipe_id }
      recipe_items = {}
      recipe.recipe_items.each do |item|
        recipe_items[item.name.downcase] = item.amount
      end
      processed_recipe_items_hash = MetricConversionService.convert_hash_to_metric(recipe_items)
      pantry_items_hash = MetricConversionService.subtract_hashes(processed_recipe_items_hash, pantry_items_hash)
    end

    recipes_to_make
  end

  private

  def self.parse_num(value)
    return value.to_f if value.is_a?(Numeric)
    return nil if value.nil?

    value = value.to_s.strip
    return nil if value.empty?

    if value =~ /^\s*(\d*\.?\d+)/
      $1.to_f
    else
      nil
    end
  end
end
