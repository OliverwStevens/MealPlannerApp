require 'rails_helper'

RSpec.describe "/recipes", type: :request do
  let(:user) { create(:user) }
  let(:recipe) { create(:recipe, user: user) }
  let(:valid_attributes) { attributes_for(:recipe) }
  let(:new_attributes) { { name: "Updated Recipe Name" } }

  describe "PATCH /update" do
    context "when not signed in" do
      it "does not update" do
        original_name = recipe.name
        patch recipe_url(recipe), params: { recipe: new_attributes }
        recipe.reload
        expect(recipe.name).to eq(original_name)
      end

      it "redirects to login" do
        patch recipe_url(recipe), params: { recipe: new_attributes }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in" do
      before { sign_in user }

      it "updates the recipe" do
        patch recipe_url(recipe), params: { recipe: new_attributes }
        recipe.reload
        expect(recipe.name).to eq("Updated Recipe Name")
      end
    end
  end
end
