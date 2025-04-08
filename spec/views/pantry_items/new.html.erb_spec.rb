require 'rails_helper'

RSpec.describe "pantry_items/new", type: :view do
  before(:each) do
    assign(:pantry_item, PantryItem.new())
  end

  it "renders new pantry_item form" do
    render

    assert_select "form[action=?][method=?]", pantry_items_path, "post" do
    end
  end
end
