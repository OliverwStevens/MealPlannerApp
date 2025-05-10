require 'rails_helper'

RSpec.describe "meals/edit", type: :view do
  let(:user) { create(:user) }
  let(:meal) { create(:meal, user: user) }  # Associate meal with user

  before do
    # Stub current_user for the view
    allow(view).to receive(:current_user).and_return(user)
    assign(:meal, meal)
  end

  it "renders the edit meal form" do
    render
    assert_select "form[action=?][method=?]", meal_path(meal), "post" do
      assert_select "input[name=?]", "meal[name]"
      assert_select "textarea[name=?]", "meal[description]"
    end
  end
end
