require 'rails_helper'

RSpec.describe "search/index", type: :view do
  let(:user) { create(:user) }
  let(:items) { create_list(:meal, 2, user: user, sharable: true, name: "Chicken Milanese") }

  context "when a search query is present" do
    before do
      paginated_items = Kaminari.paginate_array(items).page(1).per(10)
      assign(:search_items, paginated_items)
      assign(:total_items_count, items.size)
      params[:query] = "chicken"
      allow(view).to receive(:home_show_path) do |args|
        "/home/show?type=#{args[:type]}&id=#{args[:id]}"
      end
    end

    it "renders the search results with links to item show pages" do
      render
      items.each do |item|
        # Make sure the correct name is used here for the meal
        expect(rendered).to include(item.name) # expect the meal name ("Chicken Milanese") to be in the rendered output
        expect(rendered).to include("/home/show?type=meal&amp;id=#{item.id}") # Updated to use &amp;
      end
      expect(rendered).to have_css("div[data-controller='infinite-scroll']")
    end


    it "displays the search heading and result count" do
      render
      expect(rendered).to include("Search Results")
      expect(rendered).to include("Results for \"chicken\"")
      expect(rendered).to include("Found 2 items")
    end

    it "renders the pagination loader partial" do
      render
      expect(rendered).to include("data-infinite-scroll-target") # or match some specific content from your partial
    end
  end

  context "when a search query is present but no results" do
    before do
      assign(:search_items, Kaminari.paginate_array([]).page(1))
      assign(:total_items_count, 0)
      params[:query] = "nothing"
    end

    it "shows 'No results found'" do
      render
      expect(rendered).to include("No results found")
    end
  end

  context "when no search query is present" do
    before do
      assign(:search_items, Kaminari.paginate_array(items).page(1).per(10))
      assign(:total_items_count, items.size)
    end

    it "displays 'Public Content' heading" do
      render
      expect(rendered).to include("Public Content")
    end
  end

  context "when no search query and no results" do
    before do
      assign(:search_items, Kaminari.paginate_array([]).page(1))
      assign(:total_items_count, 0)
    end

    it "displays 'No public content available'" do
      render
      expect(rendered).to include("No public content available")
    end
  end
end
