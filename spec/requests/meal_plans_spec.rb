require 'rails_helper'

RSpec.describe "MealPlans", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end
  describe "GET /index" do
    it "returns http success" do
      get "/meal_plans"
      expect(response).to have_http_status(:success)
    end
  end
end
