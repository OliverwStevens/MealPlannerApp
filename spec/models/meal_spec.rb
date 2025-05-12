require 'rails_helper'

RSpec.describe Meal, type: :model do
  let(:user) { create(:user) }
  let(:recipe1) { create(:recipe, user: user) }
  let(:recipe2) { create(:recipe, user: user) }
  let(:meal) { create(:meal, user: user) }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:meal_recipes).dependent(:destroy) }
    it { is_expected.to have_many(:recipes).through(:meal_recipes) }
    it { is_expected.to have_many(:meal_plans) }
    it { is_expected.to have_one(:image_attachment) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:meal_type) }
    # Decided to remove validation for sharable because it is a bool
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:meal_type).with_values(breakfast: 0, lunch: 1, dinner: 2) }
  end

  describe 'scopes' do
    describe '.sharable' do
      let!(:sharable_meal) { create(:meal, sharable: true, user: user) }
      let!(:private_meal) { create(:meal, sharable: false, user: user) }

      it 'returns only sharable meals' do
        expect(Meal.sharable).to include(sharable_meal)
        expect(Meal.sharable).not_to include(private_meal)
      end
    end
  end

  describe '#recipes=' do
    context 'with valid recipes' do
      it 'assigns recipes to the meal' do
        meal.recipes = [ recipe1, recipe2 ]
        expect(meal.recipes).to match_array([ recipe1, recipe2 ])
      end

      it 'handles single recipe assignment' do
        meal.recipes = recipe1
        expect(meal.recipes).to eq([ recipe1 ])
      end
    end

    context 'with blank values' do
      it 'filters out blank values' do
        meal.recipes = [ recipe1, nil, '', recipe2 ]
        expect(meal.recipes).to match_array([ recipe1, recipe2 ])
      end

      it 'handles all blank values' do
        meal.recipes = [ nil, '' ]
        expect(meal.recipes).to be_empty
      end
    end

    context 'when updating recipes' do
      before { meal.recipes = [ recipe1 ] }

      it 'replaces existing recipes' do
        meal.recipes = [ recipe2 ]
        expect(meal.recipes.reload).to eq([ recipe2 ])
      end

      it 'maintains association through meal_recipes' do
        meal.recipes = [ recipe1, recipe2 ]
        expect(meal.meal_recipes.count).to eq(2)
      end
    end
  end

  describe 'searchkick' do
    it 'is expected to have searchkick enabled' do
      expect(Meal.searchkick_index).to be_present
    end
  end
end
