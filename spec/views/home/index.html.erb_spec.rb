# spec/views/home/index.html.erb_spec.rb
require 'rails_helper'

RSpec.describe "home/index.html.erb", type: :view do
  let(:recipe) { create(:recipe, sharable: true) }
  let(:meal) { create(:meal, sharable: true) }

  before do
    allow(view).to receive(:request).and_return(ActionDispatch::TestRequest.create)
  end

  context "when there are items" do
    before do
      paginated_items = Kaminari.paginate_array([ recipe, meal ]).page(1).per(10)
      assign(:items, paginated_items)
      render
    end

    it "displays the heading" do
      expect(rendered).to have_selector("h1", text: "Tasty Shares")
    end

    it "renders the infinite-scroll controller with correct data attributes" do
      expect(rendered).to have_css('[data-controller="infinite-scroll"]')
      expect(rendered).to include('data-infinite-scroll-url-value="/"')
      expect(rendered).to include('data-infinite-scroll-page-value="1"')
    end

    it "renders each item with a link to its show path" do
      expect(rendered).to have_link(href: home_show_path(type: recipe.class.name.downcase, id: recipe.id))
      expect(rendered).to have_link(href: home_show_path(type: meal.class.name.downcase, id: meal.id))
    end

    it "renders the pagination loader partial" do
      expect(rendered).to include("data-infinite-scroll-target")
    end
  end

  context "when there are no items" do
    before do
      assign(:items, Kaminari.paginate_array([]).page(1))
      render
    end

    it "displays a message indicating no public content" do
      expect(rendered).to have_content("No public content available")
    end

    it "does not render the infinite-scroll container" do
      expect(rendered).not_to have_css('[data-controller="infinite-scroll"]')
    end
  end
end
