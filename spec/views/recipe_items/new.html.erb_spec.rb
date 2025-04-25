require 'rails_helper'

RSpec.describe "recipe_items/new", type: :view do
  before(:each) do
    assign(:recipe_item, RecipeItem.new(
      recipe: nil,
      name: "MyString",
      amount: "MyString"
    ))
  end

  it "renders new recipe_item form" do
    render

    assert_select "form[action=?][method=?]", recipe_items_path, "post" do

      assert_select "input[name=?]", "recipe_item[recipe_id]"

      assert_select "input[name=?]", "recipe_item[name]"

      assert_select "input[name=?]", "recipe_item[amount]"
    end
  end
end
