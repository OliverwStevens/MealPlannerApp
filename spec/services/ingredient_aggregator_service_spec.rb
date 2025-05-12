require 'rails_helper'

RSpec.describe IngredientAggregatorService, type: :service do
  describe '.aggregate' do
    context 'with same units' do
      let(:recipe_items) do
        [
          build(:recipe_item, name: 'Flour', amount: '1 cup'),
          build(:recipe_item, name: 'Flour', amount: '0.5 cup'),
          build(:recipe_item, name: 'Sugar', amount: '2 tbsp'),
          build(:recipe_item, name: 'Sugar', amount: '1 tbsp'),
          build(:recipe_item, name: 'Salt', amount: '1 pinch'),
          build(:recipe_item, name: 'Salt', amount: '1 pinch')
        ]
      end

      it 'aggregates ingredients correctly' do
        result = IngredientAggregatorService.aggregate(recipe_items)

        expect(result['flour']).to eq([ '1.5 cups' ])
        expect(result['sugar']).to eq([ '3 tbsp' ])
        expect(result['salt']).to eq([ '2 pinches' ])
      end
    end

    context 'with mixed case and whitespace' do
      let(:recipe_items) do
        [
          build(:recipe_item, name: '  Flour ', amount: '1 cup'),
          build(:recipe_item, name: 'flour', amount: '1 cup')
        ]
      end

      it 'normalizes ingredient names before aggregation' do
        result = IngredientAggregatorService.aggregate(recipe_items)
        expect(result.keys).to eq([ 'flour' ])
        expect(result['flour']).to eq([ '2 cups' ])
      end
    end

    context 'with convertible units' do
      let(:recipe_items) do
        [
          build(:recipe_item, name: 'Butter', amount: '3 tsp'),
          build(:recipe_item, name: 'Butter', amount: '1 tbsp') # = 3 tsp
        ]
      end

      it 'converts tsp and tbsp and aggregates' do
        result = IngredientAggregatorService.aggregate(recipe_items)
        expect(result['butter']).to eq([ '2 tbsp' ])
      end
    end

    context 'with range values like "1 to 2 cups"' do
      let(:recipe_items) do
        [
          build(:recipe_item, name: 'Oil', amount: '1 to 2 cups'),
          build(:recipe_item, name: 'Oil', amount: '1 cup')
        ]
      end

      it 'uses the upper bound of the range for aggregation' do
        result = IngredientAggregatorService.aggregate(recipe_items)
        expect(result['oil']).to eq([ '3 cups' ]) # 2 + 1
      end
    end

    context 'with plural vs singular units' do
      let(:recipe_items) do
        [
          build(:recipe_item, name: 'Tomato', amount: '1 slice'),
          build(:recipe_item, name: 'Tomato', amount: '2 slices')
        ]
      end

      it 'normalizes plural unit names and aggregates correctly' do
        result = IngredientAggregatorService.aggregate(recipe_items)
        expect(result['tomato']).to eq([ '3 slices' ])
      end
    end
  end
end
