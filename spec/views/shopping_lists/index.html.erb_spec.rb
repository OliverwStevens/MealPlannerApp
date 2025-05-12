require 'rails_helper'

RSpec.describe "shopping_lists/index", type: :view do
  let(:start_date) { Date.today.beginning_of_week }
  let(:end_date)   { start_date + 6.days }

  let(:meal)       { double("Meal", name: "Tofu Stir Fry", meal_type: "dinner", recipes: []) }
  let(:meal_plan)  { double("MealPlan", meal: meal) }

  before do
    assign(:start_date, start_date)
    assign(:end_date, end_date)
  end

  context "when there are meal plans and aggregated ingredients" do
    let(:aggregated_ingredients) do
      {
        "tofu" => [ "1 block" ],
        "carrot" => [ "2 pcs", "1 pc" ]
      }
    end

    before do
      assign(:meal_plans, [ meal_plan ])
      assign(:meal_plans_by_date, {
        start_date => [ meal_plan ],
        start_date + 1.day => []
      })
      assign(:aggregated_ingredients, aggregated_ingredients)

      render
    end

    it "renders the shopping list title" do
      expect(rendered).to have_selector("h1", text: "Shopping List")
    end

    it "shows the date range" do
      expect(rendered).to have_content("from #{start_date.strftime("%B %d")} to #{end_date.strftime("%B %d")}")
    end

    it "renders each aggregated ingredient" do
      expect(rendered).to have_content("Tofu")
      expect(rendered).to have_content("Carrot")
      expect(rendered).to have_content("1 block")
      expect(rendered).to have_content("2 pcs")
    end

    it "includes search input" do
      expect(rendered).to have_selector("input#ingredient-search")
    end

    it "includes print and clear buttons" do
      expect(rendered).to have_selector("button#print-list")
      expect(rendered).to have_selector("button#clear-checked")
    end

    it "renders a list of meals in the summary" do
      expect(rendered).to have_selector(".meal-type", text: "Dinner:")
      expect(rendered).to have_selector(".meal-name", text: "Tofu Stir Fry")
    end
  end

  context "when there are no meal plans" do
    before do
      assign(:meal_plans, [])
      assign(:meal_plans_by_date, {})
      assign(:aggregated_ingredients, {})

      render
    end

    it "shows a warning message" do
      expect(rendered).to have_content("No meal plans found for the selected week")
    end

    it "suggests creating a meal plan" do
      expect(rendered).to have_link("Create a meal plan first", href: meal_plans_path)
    end
  end
end
