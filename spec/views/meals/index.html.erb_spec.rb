require 'rails_helper'

RSpec.describe "meals/index", type: :view do
  let(:user) { create(:user) }
  let!(:meals) { create_list(:meal, 2, user: user) }

  before do
    # Create a paginated collection that responds to pagination methods
    paginated_meals = Kaminari.paginate_array(meals).page(1).per(10)
    assign(:meals, paginated_meals)
    assign(:total_meals_count, 2) # Match the number of meals you created
    allow(view).to receive(:current_user).and_return(user)
  end

  it "renders the meals index page correctly" do
    render

    # Test the title and header
    expect(rendered).to include("<h1>Meals</h1>")
    expect(rendered).to include("You have 2 meal(s)")

    # Test the new meal button
    assert_select "a.floating-green-button[href=?]", new_meal_path
    assert_select "img.floating-button-icon[alt='Add meal']"

    # Test meal listings
    assert_select "#meals.food-display" do
      assert_select "a.centered-text.hover-move", count: 2
      meals.each do |meal|
        assert_select "a[href=?]", meal_path(meal)
      end
    end

    # Test infinite scroll container
    assert_select "div[data-controller='infinite-scroll']" do
      assert_select "div[data-infinite-scroll-target='entries']"
    end
  end
end
