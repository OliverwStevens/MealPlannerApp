require 'rails_helper'

RSpec.describe "meals/show", type: :view do
  let(:user) { build(:user) }
  let(:meal) { create(:meal) }
  before(:each) do
    allow(view).to receive(:user_signed_in?).and_return(true)
    allow(view).to receive(:current_user).and_return(user)

    assign(:meal, meal)
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to include(meal.name)

    expect(rendered).to include(meal.description)

    expect(rendered).to include(meal.meal_type)
    # Not checking for sharable, not sure if I will. UI kinda looks nice without it

    meal.recipes.each do |recipe|
      expect(rendered).to include(recipe.name)
    end
  end
end
