class RecipesFromPantryService
  def self.pantry_to_recipes(pantry_items_hash, current_user_recipes)
    recipes_to_make = {}

    21.times do
      # keeps track of recipes based on cost--This is iterative and subject to change from below
      recipe_cost_hash = {}

      current_user_recipes.each do |recipe|
        # Put each item in a hash
        recipe_items = {}
        recipe.recipe_items.each do |item|
          recipe_items[item.name] = item.amount
        end

        # procces the hash, formating to appropriate metric
        processed_recipe_items_hash = MetricConversionService.convert_hash_to_metric(recipe_items)

        if (pantry_items_hash.keys & processed_recipe_items_hash.keys).empty?
          # name or id?
          recipe_cost_hash[recipe.id] = 0
          # I want to move on to the next recipe and ignore the rest of the code
          next
        end

        # Using catch to exit out of below loop and skip to the next recipe
        catch :skip_outer do
          # So it should have all the keys
          total_cost = 0
          processed_recipe_items_hash.each do |key, value|
            cost = value / pantry_items_hash[key]
            if cost < 1
              # name or id?
              recipe_cost_hash[recipe.id] = 0
              throw :skip_outer
            end
            total_cost += cost
          end
          total_cost *= recipe.servings
          recipe_cost_hash[recipe.id] = total_cost
        end
      end

      break if recipe_cost_hash.values.all? { |value| value == 0 }

      recipe_to_add = recipe_cost_hash.max_by { |key, value| value }

      recipes_to_make.merge!(Hash[*recipe_to_add])



      # remove the pantry items

      recipe = current_user.recipes.find(recipe_to_add.key)
      recipe_items = {}
      recipe.recipe_items.each do |item|
        recipe_items[item.name] = item.amount
      end

      # procces the hash, formating to appropriate metric
      processed_recipe_items_hash = MetricConversionService.convert_hash_to_metric(recipe_items)

      pantry_items_hash = MetricConversionService.subtract_hashes(processed_recipe_items_hash, pantry_items_hash)
    end
    recipes_to_make
  end
end
