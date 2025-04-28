require 'rails_helper'

RSpec.describe "pantry_items/show", type: :view do
  let(:user) { create(:user) }
  let(:pantry_item) { create(:pantry_item, user: user) }

  before do
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:user_signed_in?).and_return(true)

    assign(:pantry_item, pantry_item)
  end

  it "renders attributes" do
    render
    expect(rendered).to include(pantry_item.name)
    expect(rendered).to include(pantry_item.barcode)
  end
end
