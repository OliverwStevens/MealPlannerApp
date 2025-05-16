require 'rails_helper'

RSpec.describe RecipeItem, type: :model do
  describe 'associations' do
    it { should belong_to(:recipe) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_least(2).is_at_most(200) }

    it { should validate_presence_of(:amount) }
    it { should validate_length_of(:amount).is_at_least(1).is_at_most(50) }

    context 'amount format' do
      let(:recipe) { create(:recipe) }

      it 'accepts valid amount formats' do
        valid_amounts = [
          '1 cup',
          '2.5 tbsp',
          '500 mL',
          '0.25 lb',
          '1 to 2 tsp',
          '1.5 liters',
          '3 grams'
        ]

        valid_amounts.each do |valid|
          item = build(:recipe_item, recipe: recipe, amount: valid)
          expect(item).to be_valid, "expected '#{valid}' to be valid"
        end
      end

      it 'rejects invalid amount formats' do
        invalid_amounts = [
          'cup',         # missing number
          'two cups',    # word numbers
          '1 to cup',    # invalid range
          '1-2 tbsp',    # unsupported range format
          'abc grams'    # non-numeric
        ]

        invalid_amounts.each do |invalid|
          item = build(:recipe_item, recipe: recipe, amount: invalid)
          expect(item).not_to be_valid, "expected '#{invalid}' to be invalid"
          expect(item.errors[:amount]).to include("must be like '1 cup', '2.5 lbs', or '500 mL'")
        end
      end
    end
  end
end
