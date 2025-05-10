require 'rails_helper'

RSpec.describe "/meals", type: :request do
  let(:user) { create(:user) }
  # Remove any association with recipes if not needed or fix the factory
  let(:meal) { create(:meal, user: user) }
  let(:valid_attributes) { attributes_for(:meal) }
  let(:new_attributes) { { name: "Updated Meal Name" } }

  # Add Devise test helpers
  include Devise::Test::IntegrationHelpers

  describe "PATCH /update" do
    context "when not signed in" do
      it "does not update the meal" do
        original_name = meal.name
        patch meal_url(meal), params: { meal: new_attributes }
        meal.reload
        expect(meal.name).to eq(original_name)
      end

      it "redirects to login" do
        patch meal_url(meal), params: { meal: new_attributes }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in" do
      before do
        sign_in user
      end

      it "updates the meal" do
        patch meal_url(meal), params: { meal: new_attributes }
        meal.reload
        expect(meal.name).to eq("Updated Meal Name")
      end

      it "redirects to the meal" do
        patch meal_url(meal), params: { meal: new_attributes }
        expect(response).to redirect_to(meal_url(meal))
      end
    end
  end

  describe "DELETE /destroy" do
    context "when not signed in" do
      it "does not destroy the meal" do
        meal # create the meal
        expect {
          delete meal_url(meal)
        }.not_to change(Meal, :count)
      end

      it "redirects to login" do
        delete meal_url(meal)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in" do
      before do
        sign_in user
      end

      it "destroys the meal" do
        meal # create the meal
        expect {
          delete meal_url(meal)
        }.to change(Meal, :count).by(-1)
      end

      it "redirects to meals list" do
        delete meal_url(meal)
        expect(response).to redirect_to(meals_url)
      end
    end
  end
end
