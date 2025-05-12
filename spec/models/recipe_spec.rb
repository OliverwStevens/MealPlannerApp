require 'rails_helper'

RSpec.describe Recipe, type: :model do
  describe 'validations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:meal_recipes).dependent(:destroy) }
    it { is_expected.to have_many(:meals).through(:meal_recipes) }
    it { is_expected.to have_many(:recipe_items).dependent(:destroy) }

    it { is_expected.to accept_nested_attributes_for(:recipe_items).allow_destroy(true) }

    it { is_expected.to define_enum_for(:recipe_type).with_values(%i[main side dessert appetizer snack breakfast beverage]) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_least(2).is_at_most(100) }

    it { is_expected.to validate_presence_of(:procedure) }
    it { is_expected.to validate_length_of(:procedure).is_at_least(10).is_at_most(5000) }

    it { is_expected.to validate_presence_of(:servings) }
    it { is_expected.to validate_numericality_of(:servings).only_integer.is_greater_than(0) }

    it { is_expected.to validate_presence_of(:difficulty) }
    it { is_expected.to validate_numericality_of(:difficulty).only_integer.is_greater_than(0).is_less_than(11) }

    it { is_expected.to validate_presence_of(:recipe_type) }
    it { is_expected.to validate_presence_of(:diet) }

    # NOTE: This raises a warning, so consider omitting or custom testing.
    # it { is_expected.to validate_inclusion_of(:sharable).in_array([true, false]) }

    it "is invalid without any recipe_items" do
      recipe = build(:recipe, recipe_items: [])
      recipe.recipe_items = []
      expect(recipe).not_to be_valid
      expect(recipe.errors[:recipe_items]).to include("can't be blank")
    end
  end

  describe '.sharable' do
    it "returns only recipes with sharable: true" do
      sharable_recipe = create(:recipe, sharable: true)
      unsharable_recipe = create(:recipe, sharable: false)

      expect(Recipe.sharable).to include(sharable_recipe)
      expect(Recipe.sharable).not_to include(unsharable_recipe)
    end
  end

  describe 'dependent destroy' do
    it 'destroys associated meal_recipes' do
      recipe = create(:recipe)
      create(:meal_recipe, recipe: recipe)

      expect { recipe.destroy }.to change { MealRecipe.count }.by(-1)
    end

    it 'destroys associated recipe_items' do
      recipe = create(:recipe)
      item_count = recipe.recipe_items.count

      expect { recipe.destroy }.to change { RecipeItem.count }.by(-item_count)
    end
  end



  describe '#generate_uuid' do
    it "generates and assigns a UUID before creation" do
      recipe = build(:recipe, recipe_uuid: nil) # Explicitly set uuid to nil

      expect(recipe.recipe_uuid).to be_nil
      recipe.send(:generate_uuid) # Use send to call private method
      expect(recipe.recipe_uuid).to be_present
      expect(recipe.recipe_uuid).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
    end

    it "does not overwrite existing UUID" do
      existing_uuid = SecureRandom.uuid
      recipe = build(:recipe, recipe_uuid: existing_uuid)

      recipe.send(:generate_uuid) # Use send to call private method
      expect(recipe.recipe_uuid).to eq(existing_uuid)
    end
  end

  describe 'callbacks' do
    it "auto-generates UUID on create" do
      recipe = create(:recipe, recipe_uuid: nil)
      expect(recipe.recipe_uuid).to be_present
    end
  end
end
