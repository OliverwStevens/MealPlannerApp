require 'rails_helper'

RSpec.describe "meals/new", type: :view do
  let(:user) { create(:user) }
  let(:meal) { build(:meal, user: user) }
  let(:recipes) { create_list(:recipe, 3, user: user) }

  before do
    allow(view).to receive(:current_user).and_return(user)
    assign(:meal, meal)
    assign(:recipes, recipes) # Make sure recipes are available in the view
  end

  it "renders new meal form" do
    render

    assert_select "form.meal-form[action=?][method=?][data-turbo=?]",
                  meals_path, "post", "false" do
      # Error explanation (should be hidden when no errors)
      assert_select ".error-explanation", count: 0

      # Name field
      assert_select "input[name=?]", "meal[name]"
      assert_select "label[for=?]", "meal_name", text: "Name"

      # Description field
      assert_select "textarea[name=?]", "meal[description]"
      assert_select "label[for=?]", "meal_description", text: "Description"

      # Meal type select
      assert_select "select[name=?]", "meal[meal_type]"
      assert_select "label[for=?]", "meal_meal_type", text: "Meal type"
      Meal.meal_types.keys.each do |meal_type|
        assert_select "option[value=?]", meal_type
      end

      # Recipes multi-select
      assert_select "select[name=?][multiple]", "meal[recipe_ids][]"
      assert_select "label[for=?]", "meal_recipe_ids", text: "Recipes"
      recipes.each do |recipe|
        assert_select "option[value=?]", recipe.id.to_s, text: recipe.name
      end

      # Sharable checkbox
      assert_select "input[type=checkbox][name=?]", "meal[sharable]"
      assert_select "label[for=?]", "meal_sharable", text: "Sharable"
      assert_select "input[name=?][checked]", "meal[sharable]"

      # Hidden user_id field
      assert_select "input[type=hidden][name=?][value=?]", "meal[user_id]", user.id.to_s

      # Image upload
      assert_select "label[for=?]", "meal_image", text: "Image"
      assert_select ".file-upload" do
        assert_select "label.custom-file-upload", text: "Upload image"
        assert_select "input.hidden-file-input[type=file][name=?]", "meal[image]"
        assert_select "input[accept=?]", "image/png,image/jpeg,image/jpg"
      end

      # Submit button
      assert_select "input[type=submit]"
    end
  end

  context "when meal has errors" do
    before do
      meal.errors.add(:name, "can't be blank")
      meal.errors.add(:description, "is too short")
    end

    it "displays error messages" do
      render

      assert_select ".error-explanation" do
        assert_select "h2", text: /2 errors/
        assert_select "li", text: /Name can't be blank/
        assert_select "li", text: /Description is too short/
      end
    end
  end
end
