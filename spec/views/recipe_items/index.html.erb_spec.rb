require 'rails_helper'

RSpec.describe "recipe_items/index", type: :view do
  before(:each) do
    assign(:recipe_items, [
      RecipeItem.create!(
        recipe: nil,
        name: "Name",
        amount: "Amount"
      ),
      RecipeItem.create!(
        recipe: nil,
        name: "Name",
        amount: "Amount"
      )
    ])
  end

  it "renders a list of recipe_items" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Amount".to_s), count: 2
  end
end
