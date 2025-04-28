require 'rails_helper'

RSpec.describe "pantry_items/new", type: :view do
  let(:user) { create(:user) }

  before do
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:user_signed_in?).and_return(true)

    assign(:pantry_item, PantryItem.new)
  end

  it "renders new pantry_item form" do
    render

    # Basic assertions
    expect(rendered).to have_selector("form[action='#{pantry_items_path}'][method='post']")
    expect(rendered).to have_selector("input[type='hidden'][name='pantry_item[name]']", visible: false)
    expect(rendered).to have_selector("input[type='hidden'][name='pantry_item[barcode]'][id='barcode-result']", visible: false)
    expect(rendered).to have_selector("input[type='hidden'][name='pantry_item[user_id]'][value='#{user.id}']", visible: false)

    expect(rendered).to have_selector("video#scanner-video")

    expect(rendered).to have_selector("input[type='submit'][class='hidden-submit']", visible: false)
  end
end
