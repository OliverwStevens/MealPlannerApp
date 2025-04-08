require 'rails_helper'

RSpec.describe "pantry_items/edit", type: :view do
  let(:pantry_item) {
    PantryItem.create!()
  }

  before(:each) do
    assign(:pantry_item, pantry_item)
  end

  it "renders the edit pantry_item form" do
    render

    assert_select "form[action=?][method=?]", pantry_item_path(pantry_item), "post" do
    end
  end
end
