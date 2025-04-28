require 'rails_helper'

RSpec.describe "recipes/show", type: :view do
  let(:user) { build(:user) }
  let(:recipe) { create(:recipe) }
  before(:each) do
    allow(view).to receive(:user_signed_in?).and_return(true)
    allow(view).to receive(:current_user).and_return(user)

    assign(:recipe, recipe)
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to include(recipe.name)

    expect(rendered).to include(recipe.procedure)

    expect(rendered).to include(recipe.servings.to_s)

    expect(rendered).to include(recipe.difficulty.to_s)

    expect(rendered).to include(recipe.prep_time)
  end
end
