require 'rails_helper'

RSpec.describe "recipes/index", type: :view do
  before(:each) do
    assign(:recipes, [
      Recipe.create!(
        name: "Name",
        procedure: "MyText",
        servings: 2,
        difficulty: 3,
        prep_time: "Prep Time"
      ),
      Recipe.create!(
        name: "Name",
        procedure: "MyText",
        servings: 2,
        difficulty: 3,
        prep_time: "Prep Time"
      )
    ])
  end

  it "renders a list of recipes" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("MyText".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(2.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(3.to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Prep Time".to_s), count: 2
  end
end
