require 'rails_helper'

RSpec.describe Recipe, type: :model do
  describe '#generate_uuid' do
    it "generates and assigns a UUID before creation" do
      recipe = build(:recipe, recipe_uuid: nil) # Explicitly set uuid to nil

      expect(recipe.recipe_uuid).to be_nil
      recipe.send(:generate_uuid) # Use send to call private method
      expect(recipe.recipe_uuid).to be_present
      expect(recipe.recipe_uuid).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
    end

    it "does not overwrite existing UUID" do
      existing_uuid = SecureRandom.uuid
      recipe = build(:recipe, recipe_uuid: existing_uuid)

      recipe.send(:generate_uuid) # Use send to call private method
      expect(recipe.recipe_uuid).to eq(existing_uuid)
    end
  end

  describe 'callbacks' do
    it "auto-generates UUID on create" do
      recipe = create(:recipe, recipe_uuid: nil)
      expect(recipe.recipe_uuid).to be_present
    end
  end
end
