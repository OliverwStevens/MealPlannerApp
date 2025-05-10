require 'rails_helper'

RSpec.describe "recipes/index", type: :view do
  let(:user) { create(:user) }
  let!(:recipes) { create_list(:recipe, 2, user: user) }

  before do
    # Create paginated collection
    paginated_recipes = Kaminari.paginate_array(recipes).page(1).per(10)
    assign(:recipes, paginated_recipes)
    assign(:total_recipes_count, 2)
    allow(view).to receive(:user_signed_in?).and_return(true)
    allow(view).to receive(:current_user).and_return(user)
  end

  it "renders the recipes index page correctly" do
    render

    # Test basic content
    expect(rendered).to include("<h1>Recipes</h1>")
    expect(rendered).to include("You have 2 recipe(s)")

    # Test new recipe button
    assert_select "a.floating-green-button[href=?]", new_recipe_path
    assert_select "img.floating-button-icon[alt='Add recipe']"

    # Test recipe listings
    assert_select "#recipes.food-display" do
      assert_select "a.centered-text.hover-move", count: 2
      recipes.each do |recipe|
        assert_select "a[href=?]", recipe_path(recipe)
      end
    end

    # Test infinite scroll container
    assert_select "div[data-controller='infinite-scroll']" do
      assert_select "div[data-infinite-scroll-target='entries']"
    end
  end
end
