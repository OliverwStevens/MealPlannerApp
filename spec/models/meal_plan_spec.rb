require 'rails_helper'

RSpec.describe MealPlan, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:meal) }
  end

  describe 'validations' do
    subject { create(:meal_plan) }

    it { should validate_presence_of(:date) }

    it {
      should validate_uniqueness_of(:date)
        .scoped_to(:user_id, :meal_id)
        .with_message("already has this meal assigned")
    }
  end


  describe 'uniqueness scoped to user and meal' do
    let(:user) { create(:user) }
    let(:meal) { create(:meal) }
    let(:date) { Date.today }

    before do
      create(:meal_plan, user: user, meal: meal, date: date)
    end

    it 'does not allow duplicate meal plans for same user, meal, and date' do
      duplicate = build(:meal_plan, user: user, meal: meal, date: date)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:date]).to include("already has this meal assigned")
    end

    it 'allows same date for different user' do
      other_user = create(:user)
      meal_plan = build(:meal_plan, user: other_user, meal: meal, date: date)
      expect(meal_plan).to be_valid
    end

    it 'allows same date and user for different meal' do
      other_meal = create(:meal)
      meal_plan = build(:meal_plan, user: user, meal: other_meal, date: date)
      expect(meal_plan).to be_valid
    end
  end
end
