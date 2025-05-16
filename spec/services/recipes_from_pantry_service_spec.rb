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
        create_list(:recipe, 3, user: user, recipe_items: [
          build(:recipe_item, item_name: "flour", item_amount: "2 cups"),
          build(:recipe_item, item_name: "sugar", item_amount: "1 cup")
        ])
      end

      it 'returns an empty hash' do
        result = RecipesFromPantryService.pantry_to_recipes(pantry_items_hash, recipes)
        expect(result).to eq({})
      end
    end

    context 'when recipes partially match pantry items' do
      let!(:recipe1) do
        create(:recipe, user: user, servings: 2, recipe_items: [
          build(:recipe_item, item_name: "organic chopped onion", item_amount: "100 g"),
          build(:recipe_item, item_name: "flour", item_amount: "2 cups") # not in pantry
        ])
      end

      let!(:recipe2) do
        create(:recipe, user: user, servings: 4, recipe_items: [
          build(:recipe_item, item_name: "organic chopped onion", item_amount: "200 g"),
          build(:recipe_item, item_name: "organic fruit layered bars variety pack (pineapple passionfruit, raspberry lemonade, strawberry banana)", item_amount: "1 package")
        ])
      end

      before do
        allow(MetricConversionService).to receive(:convert_hash_to_metric) do |hash|
          hash
        end

        allow(MetricConversionService).to receive(:subtract_hashes) do |recipe_hash, pantry_hash|
          result = pantry_hash.dup
          recipe_hash.each do |key, value|
            if result.key?(key)
              result[key] = (result[key].to_f - value.to_f).to_s + " g" if key == "organic chopped onion"
              result[key] = (result[key].to_f - value.to_f).to_s + " packages" if key == "organic fruit layered bars variety pack (pineapple passionfruit, raspberry lemonade, strawberry banana)"
            end
          end
          result
        end
      end

      it 'only returns recipes with all ingredients in pantry' do
        result = RecipesFromPantryService.pantry_to_recipes(pantry_items_hash, [ recipe1, recipe2 ])
        expect(result.keys).to include(recipe2.id)
        expect(result.keys).not_to include(recipe1.id)
      end
    end

    context 'when multiple recipes match pantry items' do
      let!(:recipe1) do
        create(:recipe, user: user, servings: 2, recipe_items: [
          build(:recipe_item, item_name: "organic chopped onion", item_amount: "100 g")
        ])
      end

      let!(:recipe2) do
        create(:recipe, user: user, servings: 3, recipe_items: [
          build(:recipe_item, item_name: "organic chopped onion", item_amount: "150 g")
        ])
      end

      before do
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
                result[key] = result[key].to_f - value.to_f
              end
            end
          end
          result
        end
      end

      it 'prioritizes recipes with higher cost' do
        allow(user).to receive(:recipes).and_return(Recipe.where(id: [ recipe1.id, recipe2.id ]))

        result = RecipesFromPantryService.pantry_to_recipes({ "organic chopped onion" => 640.0 }, [ recipe1, recipe2 ])
        expect(result.keys.first).to eq(recipe2.id)
      end
    end

    context 'when all recipes have zero cost' do
      let!(:recipes) do
        create_list(:recipe, 3, user: user, recipe_items: [
          build(:recipe_item, item_name: "flour", item_amount: "2 cups") # not in pantry
        ])
      end

      before do
        allow(MetricConversionService).to receive(:convert_hash_to_metric).and_return({})
        allow(MetricConversionService).to receive(:subtract_hashes).and_return(pantry_items_hash)
      end

      it 'handles the nil case properly' do
        expect {
          result = RecipesFromPantryService.pantry_to_recipes(pantry_items_hash, recipes)
          expect(result).to eq({})
        }.not_to raise_error
      end
    end

    context 'when handling the max possible recipes' do
      let!(:recipe) do
        create(:recipe, user: user, servings: 1, recipe_items: [
          build(:recipe_item, item_name: "organic chopped onion", item_amount: "100 g")
        ])
      end

      before do
        allow(MetricConversionService).to receive(:convert_hash_to_metric) do |hash|
          { "organic chopped onion" => 100.0 }
        end

        allow(MetricConversionService).to receive(:subtract_hashes) do |recipe_hash, pantry_hash|
          if pantry_hash["organic chopped onion"] > 100.0
            { "organic chopped onion" => pantry_hash["organic chopped onion"] - 100.0 }
          else
            { "organic chopped onion" => 0.0 }
          end
        end

        allow(user).to receive(:recipes).and_return(Recipe.where(id: recipe.id))
      end

      it 'stops after pantry is depleted' do
        result = RecipesFromPantryService.pantry_to_recipes({ "organic chopped onion" => 640.0 }, [ recipe ])
        expect(result[recipe.id]).to eq(6)
      end
    end
  end
end
