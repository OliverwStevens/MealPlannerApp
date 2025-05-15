require 'rails_helper'

RSpec.describe RecipesFromPantryService do
  let(:user) { create(:user) }
  let(:pantry_items_hash) { { "organic chopped onion" => "640.0 g", "organic fruit layered bars variety pack (pineapple passionfruit, raspberry lemonade, strawberry banana)" => "2 packages" } }

  describe '.pantry_to_recipes' do
    context 'when there are no recipes' do
      it 'returns an empty hash' do
        result = RecipesFromPantryService.pantry_to_recipes(pantry_items_hash, [])
        expect(result).to eq({})
      end
    end

    context 'when no recipe matches the pantry items' do
      let!(:recipes) do
        create_list(:recipe, 3, user: user) do |recipe, i|
          create(:recipe_item, recipe: recipe, name: "flour", amount: "2 cups")
          create(:recipe_item, recipe: recipe, name: "sugar", amount: "1 cup")
        end
      end

      it 'returns an empty hash' do
        result = RecipesFromPantryService.pantry_to_recipes(pantry_items_hash, recipes)
        expect(result).to eq({})
      end
    end

    context 'when recipes partially match pantry items' do
      let!(:recipe1) do
        create(:recipe, user: user, servings: 2) do |recipe|
          create(:recipe_item, recipe: recipe, name: "organic chopped onion", amount: "100 g")
          create(:recipe_item, recipe: recipe, name: "flour", amount: "2 cups") # not in pantry
        end
      end

      let!(:recipe2) do
        create(:recipe, user: user, servings: 4) do |recipe|
          create(:recipe_item, recipe: recipe, name: "organic chopped onion", amount: "200 g")
          create(:recipe_item, recipe: recipe, name: "organic fruit layered bars variety pack (pineapple passionfruit, raspberry lemonade, strawberry banana)", amount: "1 package")
        end
      end

      before do
        # Mock the MetricConversionService for consistent behavior
        allow(MetricConversionService).to receive(:convert_hash_to_metric) do |hash|
          # Just pass through the hash for testing simplicity
          hash
        end

        allow(MetricConversionService).to receive(:subtract_hashes) do |recipe_hash, pantry_hash|
          # Simple mock implementation
          result = pantry_hash.dup
          recipe_hash.each do |key, value|
            if result.key?(key)
              # This is simplistic and doesn't handle actual conversions
              result[key] = (result[key].to_f - value.to_f).to_s + " g" if key == "organic chopped onion"
              result[key] = (result[key].to_f - value.to_f).to_s + " packages" if key == "organic fruit layered bars variety pack (pineapple passionfruit, raspberry lemonade, strawberry banana)"
            end
          end
          result
        end
      end

      it 'only returns recipes with all ingredients in pantry' do
        # For recipe1, the flour is missing from pantry
        # For recipe2, all ingredients are in pantry
        result = RecipesFromPantryService.pantry_to_recipes(pantry_items_hash, [ recipe1, recipe2 ])
        expect(result.keys).to include(recipe2.id)
        expect(result.keys).not_to include(recipe1.id)
      end
    end

    context 'when multiple recipes match pantry items' do
      let!(:recipe1) do
        create(:recipe, user: user, servings: 2) do |recipe|
          create(:recipe_item, recipe: recipe, name: "organic chopped onion", amount: "100 g")
        end
      end

      let!(:recipe2) do
        create(:recipe, user: user, servings: 3) do |recipe|
          create(:recipe_item, recipe: recipe, name: "organic chopped onion", amount: "150 g")
        end
      end

      before do
        # Mock the conversion service
        allow(MetricConversionService).to receive(:convert_hash_to_metric) do |hash|
          converted_hash = {}
          hash.each do |key, value|
            if value.include?("g")
              converted_hash[key] = value.to_f
            else
              converted_hash[key] = value
            end
          end
          converted_hash
        end

        allow(MetricConversionService).to receive(:subtract_hashes) do |recipe_hash, pantry_hash|
          result = pantry_hash.dup
          recipe_hash.each do |key, value|
            if result.key?(key)
              if key == "organic chopped onion"
                result[key] = result[key] - value
              else
                # Handle the package subtraction if needed
                result[key] = result[key].to_f - value.to_f
              end
            end
          end
          result
        end
      end

      it 'prioritizes recipes with higher cost' do
        allow(user).to receive(:recipes).and_return(Recipe.where(id: [ recipe1.id, recipe2.id ]))

        # Recipe2 uses more onions (150g * 3 servings = 450g) compared to Recipe1 (100g * 2 servings = 200g)
        result = RecipesFromPantryService.pantry_to_recipes({ "organic chopped onion" => 640.0 }, [ recipe1, recipe2 ])

        # Since recipe2 has a higher cost (uses more ingredients), it should be selected first
        expect(result.keys.first).to eq(recipe2.id)
      end
    end

    context 'when all recipes have zero cost' do
      let!(:recipes) do
        create_list(:recipe, 3, user: user) do |recipe|
          create(:recipe_item, recipe: recipe, name: "flour", amount: "2 cups") # not in pantry
        end
      end

      before do
        allow(MetricConversionService).to receive(:convert_hash_to_metric).and_return({})
        allow(MetricConversionService).to receive(:subtract_hashes).and_return(pantry_items_hash)
      end

      it 'handles the nil case properly' do
        # This test specifically checks for the bug we identified
        # The service should handle the case where recipe_to_add is nil
        expect {
          result = RecipesFromPantryService.pantry_to_recipes(pantry_items_hash, recipes)
          expect(result).to eq({})
        }.not_to raise_error
      end
    end

    context 'when handling the max possible recipes' do
      let!(:recipe) do
        create(:recipe, user: user, servings: 1) do |r|
          create(:recipe_item, recipe: r, name: "organic chopped onion", amount: "100 g")
        end
      end

      before do
        allow(MetricConversionService).to receive(:convert_hash_to_metric) do |hash|
          # Just return the original hash for simplicity
          { "organic chopped onion" => 100.0 }
        end

        allow(MetricConversionService).to receive(:subtract_hashes) do |recipe_hash, pantry_hash|
          if pantry_hash["organic chopped onion"] > 100.0
            # Decrease pantry amount by recipe amount
            { "organic chopped onion" => pantry_hash["organic chopped onion"] - 100.0 }
          else
            # No more ingredients left
            { "organic chopped onion" => 0.0 }
          end
        end

        allow(user).to receive(:recipes).and_return(Recipe.where(id: recipe.id))
      end

      it 'stops after pantry is depleted' do
        # We have 640g of onions, recipe uses 100g per serving
        # Should be able to make the recipe 6 times (600g total)
        result = RecipesFromPantryService.pantry_to_recipes({ "organic chopped onion" => 640.0 }, [ recipe ])

        # Check that the recipe was added to the result 6 times
        expect(result[recipe.id]).to eq(6)
      end
    end
  end
end
