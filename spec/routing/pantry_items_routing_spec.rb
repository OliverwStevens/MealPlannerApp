require "rails_helper"

RSpec.describe PantryItemsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/pantry_items").to route_to("pantry_items#index")
    end

    it "routes to #new" do
      expect(get: "/pantry_items/new").to route_to("pantry_items#new")
    end

    it "routes to #show" do
      expect(get: "/pantry_items/1").to route_to("pantry_items#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/pantry_items/1/edit").to route_to("pantry_items#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/pantry_items").to route_to("pantry_items#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/pantry_items/1").to route_to("pantry_items#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/pantry_items/1").to route_to("pantry_items#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/pantry_items/1").to route_to("pantry_items#destroy", id: "1")
    end
  end
end
