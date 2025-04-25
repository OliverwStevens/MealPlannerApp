require 'rails_helper'

RSpec.describe "recipe_items/edit", type: :view do
  let(:recipe_item) {
    RecipeItem.create!(
      recipe: nil,
      name: "MyString",
      amount: "MyString"
    )
  }

  before(:each) do
    assign(:recipe_item, recipe_item)
  end

  it "renders the edit recipe_item form" do
    render

    assert_select "form[action=?][method=?]", recipe_item_path(recipe_item), "post" do

      assert_select "input[name=?]", "recipe_item[recipe_id]"

      assert_select "input[name=?]", "recipe_item[name]"

      assert_select "input[name=?]", "recipe_item[amount]"
    end
  end
end
