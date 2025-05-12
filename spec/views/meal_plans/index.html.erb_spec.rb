require 'rails_helper'

RSpec.describe "meal_plans/index", type: :view do
  let(:user) { create(:user) }
  let(:days) { (Date.today.beginning_of_week..Date.today.beginning_of_week + 6.days).to_a }
  let(:meal_types) { %w[breakfast lunch dinner] }

  let(:meals) do
    meal_types.each_with_object({}) do |type, hash|
      hash[type] = create_list(:meal, 2, user: user, meal_type: type)
    end
  end

  let(:todays_meals) do
    meal_types.index_with do |type|
      create(:meal_plan, user: user, meal: meals[type].first, date: Date.today)
    end
  end

  before do
    assign(:start_date, Date.today.beginning_of_week)
    assign(:meal_types, meal_types)
    assign(:days, days)
    assign(:meals_by_type, meals)
    assign(:todays_meals, todays_meals)

    allow(view).to receive(:current_user).and_return(user)
    allow(user).to receive_message_chain(:meal_plans, :joins, :find_by) do |*args|
      create(:meal_plan, user: user, meal: create(:meal), date: Date.today)
    end

    render
  end

  it "renders the weekly meal plan heading" do
    expect(rendered).to include("Weekly Meal Plan")
  end

  it "renders the start_date form" do
    expect(rendered).to have_selector("form.meal-plan-form")
    expect(rendered).to have_selector("input[type='date']")
  end

  it "renders the desktop meal plan table with correct days and meal types" do
    meal_types.each do |meal_type|
      expect(rendered).to include(meal_type.capitalize)
    end

    days.each do |day|
      expect(rendered).to include(day.strftime('%A, %b %d'))
    end
  end

  it "renders select fields for meals" do
    expected_count = days.size * meal_types.size * 2 # desktop + mobile
    expect(rendered).to have_selector("select.meal-select", count: expected_count)
  end

  it "renders mobile view cards for each day" do
    expect(rendered).to have_selector(".meal-mobile-cards .meal-day-card", count: 7)
  end

  it "shows today's meals in sidebar" do
    expect(rendered).to include("Today's Meals")
    meal_types.each do |meal_type|
      expect(rendered).to include(meal_type.capitalize)
      expect(rendered).to include(todays_meals[meal_type].meal.name)
    end
  end

  it "renders the auto-generate and clear buttons" do
    expect(rendered).to have_button("Auto-Generate Meals")
    expect(rendered).to have_button("Clear Week")
  end
end
