require 'rails_helper'

RSpec.describe "recipes/new", type: :view do
  before(:each) do
    assign(:recipe, Recipe.new(
      name: "MyString",
      procedure: "MyText",
      servings: 1,
      difficulty: 1,
      prep_time: "MyString"
    ))
  end

  it "renders new recipe form" do
    render

    assert_select "form[action=?][method=?]", recipes_path, "post" do

      assert_select "input[name=?]", "recipe[name]"

      assert_select "textarea[name=?]", "recipe[procedure]"

      assert_select "input[name=?]", "recipe[servings]"

      assert_select "input[name=?]", "recipe[difficulty]"

      assert_select "input[name=?]", "recipe[prep_time]"
    end
  end
end
