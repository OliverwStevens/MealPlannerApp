require 'rails_helper'

RSpec.describe "pantry_items/show", type: :view do
  before(:each) do
    assign(:pantry_item, PantryItem.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
