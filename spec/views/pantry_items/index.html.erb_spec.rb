require 'rails_helper'

RSpec.describe "pantry_items/index", type: :view do
  let(:user) { create(:user) }
  let!(:pantry_items) { create_list(:pantry_item, 2, user: user) }

  before do
    paginated_items = Kaminari.paginate_array(pantry_items).page(1).per(10)
    assign(:pantry_items, paginated_items)
    assign(:total_pantry_items_count, 2)
    allow(view).to receive(:user_signed_in?).and_return(true)
    allow(view).to receive(:current_user).and_return(user)
  end

  it "renders the pantry items index page correctly" do
    render

    # Test header and count
    expect(rendered).to have_selector('h1.padded', text: 'You have 2 items in your pantry')

    # Test the new item button
    assert_select "a.floating-green-button[href=?]", new_pantry_item_path
    assert_select "img.floating-button-icon[alt='Add pantry item']"

    # Test infinite scroll container
    assert_select "div[data-controller='infinite-scroll']" do
      # Test the entries container with correct ID and class
      assert_select "div#pantry_items.food-display[data-infinite-scroll-target='entries']" do
        pantry_items.each do |item|
          assert_select "a[href=?]", pantry_item_path(item)
        end
      end
    end

    # Test individual items (assuming _pantry_item partial renders name and image)
    pantry_items.each do |item|
      expect(rendered).to include(item.name)
      if item.img_url.present?
        expect(rendered).to have_css("img[src*='#{File.basename(item.img_url)}']")
      end
    end
  end

  context "when there are no items" do
    before do
      assign(:pantry_items, Kaminari.paginate_array([]).page(1).per(10))
      assign(:total_pantry_items_count, 0)
      render
    end

    it "shows the empty pantry message" do
      expect(rendered).to have_selector('h2.centered-big-title', text: 'You need to go shopping!')
    end
  end
end
