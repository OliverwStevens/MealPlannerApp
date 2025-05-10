require 'rails_helper'

RSpec.describe "ShoppingLists", type: :request do
  let(:user) { create(:user) }

  before do
    login_as(user, scope: :user) # This is perfect
  end

  describe "GET /index" do
    it "returns http success" do
      get shopping_lists_path
      expect(response).to have_http_status(:success)
    end
  end
end
