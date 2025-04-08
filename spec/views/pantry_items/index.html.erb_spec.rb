require 'rails_helper'

RSpec.describe "pantry_items/index", type: :view do
  before(:each) do
    assign(:pantry_items, [
      PantryItem.create!(),
      PantryItem.create!()
    ])
  end

  it "renders a list of pantry_items" do
    render
    cell_selector = 'div>p'
  end
end
