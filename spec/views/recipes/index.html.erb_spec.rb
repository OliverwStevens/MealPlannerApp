require 'rails_helper'

RSpec.describe "recipes/index", type: :view do
  let(:user) { create(:user) }
  let!(:recipes) { create_list(:recipe, 2, user: user) }

  before do
    allow(view).to receive(:user_signed_in?).and_return(true)
    allow(view).to receive(:current_user).and_return(user)
    assign(:recipes, recipes)
  end

  it "renders a list of recipes" do
    render
    recipes.each do |recipe|
      expect(rendered).to include(recipe.name)
    end
  end
end
