require 'rails_helper'

RSpec.describe "recipe_items/show", type: :view do
  before(:each) do
    assign(:recipe_item, RecipeItem.create!(
      recipe: nil,
      name: "Name",
      amount: "Amount"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Amount/)
  end
end
