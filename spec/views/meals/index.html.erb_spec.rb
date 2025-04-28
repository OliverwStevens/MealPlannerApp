require 'rails_helper'

RSpec.describe "meals/index", type: :view do
  before(:each) do
    assign(:meals, [
      Meal.create!(
        name: "Name",
        description: "MyText",
        user: nil
      ),
      Meal.create!(
        name: "Name",
        description: "MyText",
        user: nil
      )
    ])
  end

  it "renders a list of meals" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("MyText".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
  end
end
