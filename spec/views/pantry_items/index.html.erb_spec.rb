require 'rails_helper'

RSpec.describe "pantry_items/index", type: :view do
  let(:user) { create(:user) }

  before(:each) do
    allow(view).to receive(:user_signed_in?).and_return(true)
    allow(view).to receive(:current_user).and_return(user)
    assign(:pantry_items, create_list(:pantry_item, 2, user: user))
  end

  it "renders the page title" do
    render
    expect(rendered).to have_selector('h1', text: 'You have 2 items in your pantry')
  end

  it "renders a list of pantry items" do
    pantry_items = assign(:pantry_items, create_list(:pantry_item, 2, user: user))

    render

    pantry_items.each do |item|
      expect(rendered).to include(item.name)
    end

    pantry_items.each do |item|
      expect(rendered).to have_css("img[src*='#{File.basename(item.img_url)}']") if item.img_url.present?
    end
  end
end
