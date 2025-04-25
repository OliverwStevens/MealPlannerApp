require 'rails_helper'

RSpec.describe "recipes/edit", type: :view do
  let(:recipe) {
    Recipe.create!(
      name: "MyString",
      procedure: "MyText",
      servings: 1,
      difficulty: 1,
      prep_time: "MyString"
    )
  }

  before(:each) do
    assign(:recipe, recipe)
  end

  it "renders the edit recipe form" do
    render

    assert_select "form[action=?][method=?]", recipe_path(recipe), "post" do

      assert_select "input[name=?]", "recipe[name]"

      assert_select "textarea[name=?]", "recipe[procedure]"

      assert_select "input[name=?]", "recipe[servings]"

      assert_select "input[name=?]", "recipe[difficulty]"

      assert_select "input[name=?]", "recipe[prep_time]"
    end
  end
end
