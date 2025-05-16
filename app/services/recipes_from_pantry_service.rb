class RecipesFromPantryService
  def self.pantry_to_recipes(pantry_items_hash, current_user_recipes)
    recipes_to_make = {}

    21.times do
      # Keeps track of recipes based on cost
      recipe_cost_hash = {}

      current_user_recipes.each do |recipe|
        # Put each item in a hash
        recipe_items = {}
        recipe.recipe_items.each do |item|
          recipe_items[item.name] = item.amount
        end

        # Process the hash, formatting to appropriate metric
        processed_recipe_items_hash = MetricConversionService.convert_hash_to_metric(recipe_items)

        # Check if all recipe items are in pantry
        unless processed_recipe_items_hash.keys.all? { |key| pantry_items_hash.key?(key) }
          recipe_cost_hash[recipe.id] = 0
          next
        end

        # Using catch to exit out of below loop and skip to the next recipe
        catch :skip_outer do
          # Calculate cost based on total ingredient usage
          total_cost = 0
          processed_recipe_items_hash.each do |key, value|
            pantry_value = pantry_items_hash[key]
            next unless pantry_value # Skip if pantry doesn't have this item
            cost = parse_num(pantry_value) / parse_num(value)
            if cost < 1
              recipe_cost_hash[recipe.id] = 0
              throw :skip_outer
            end
            total_cost += parse_num(value) # Sum ingredient amounts
          end
          total_cost *= recipe.servings
          recipe_cost_hash[recipe.id] = total_cost
        end
      end

      # Break if no valid recipes (all costs are 0 or hash is empty)
      break if recipe_cost_hash.empty? || recipe_cost_hash.values.all? { |value| value == 0 }

      recipe_to_add = recipe_cost_hash.max_by { |key, value| value }
      recipe_id = recipe_to_add[0]

      # Increment count of how many times the recipe can be made
      recipes_to_make[recipe_id] = (recipes_to_make[recipe_id] || 0) + 1

      # Remove the pantry items
      recipe = current_user_recipes.find { |r| r.id == recipe_id }
      recipe_items = {}
      recipe.recipe_items.each do |item|
        recipe_items[item.name] = item.amount
      end

      # Process the hash, formatting to appropriate metric
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

    # Match numbers (integer or decimal) at the start, ignoring units
    if value =~ /^\s*(\d*\.?\d+)/
      $1.to_f
    else
      nil
    end
  end
end
