require 'rails_helper'

RSpec.describe MealRecipe, type: :model do
  describe 'associations' do
    it { should belong_to(:meal) }
    it { should belong_to(:recipe) }
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      meal_recipe = build(:meal_recipe)
      expect(meal_recipe).to be_valid
    end

    it 'is invalid without a meal' do
      meal_recipe = build(:meal_recipe, meal: nil)
      expect(meal_recipe).not_to be_valid
      expect(meal_recipe.errors[:meal]).to include("must exist")
    end

    it 'is invalid without a recipe' do
      meal_recipe = build(:meal_recipe, recipe: nil)
      expect(meal_recipe).not_to be_valid
      expect(meal_recipe.errors[:recipe]).to include("must exist")
    end
  end
end
