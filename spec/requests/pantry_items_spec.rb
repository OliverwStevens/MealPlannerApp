require 'rails_helper'

RSpec.describe "/pantry_items", type: :request do
  let(:user) {
    User.create!(
      email: 'test@example.com',
      password: 'password123',
      password_confirmation: 'password123',
      first_name: 'Test',
      last_name: 'User'
    )
  }
  let(:valid_attributes) {
    {
      name: 'Organic semi sweet chocolate baking chips',
      barcode: '099482494834',
      img_url: 'https://images.openfoodfacts.org/images/products/009/948/249/4834/front_en.3.200.jpg',
      user_id: user.id
    }
  }

  let(:invalid_attributes) {
    {
      name: '',
      barcode: nil
    }
  }

  before do
    user

    post user_session_path, params: {
      user: {
        email: user.email,
        password: 'password123'
      }
    }
    # follow_redirect!
  end

  describe "GET /index" do
    it "renders a successful response" do
      PantryItem.create! valid_attributes
      get pantry_items_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      pantry_item = PantryItem.create! valid_attributes
      get pantry_item_url(pantry_item)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_pantry_item_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      pantry_item = PantryItem.create! valid_attributes
      get edit_pantry_item_url(pantry_item)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new PantryItem" do
        expect {
          post pantry_items_url, params: { pantry_item: valid_attributes }
        }.to change(PantryItem, :count).by(1)
      end

      it "redirects to the created pantry_item" do
        post pantry_items_url, params: { pantry_item: valid_attributes }
        expect(response).to redirect_to(new_pantry_item_url)
      end
    end

    context "with invalid parameters" do
      it "does not create a new PantryItem" do
        expect {
          post pantry_items_url, params: { pantry_item: invalid_attributes }
        }.to change(PantryItem, :count).by(0)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post pantry_items_url, params: { pantry_item: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        {
          name: 'Organic Fruit Layered Bars Variety Pack (Pineapple Passionfruit, Raspberry Lemonade, Strawberry Banana)',
          barcode: '190912100865',
          img_url: 'https://images.openfoodfacts.org/images/products/019/091/210/0865/front_en.3.200.jpg'
        }
      }

      it "updates the requested pantry_item" do
        pantry_item = PantryItem.create! valid_attributes
        patch pantry_item_url(pantry_item), params: { pantry_item: new_attributes }
        pantry_item.reload
        expect(pantry_item.name).to eq('Organic Fruit Layered Bars Variety Pack (Pineapple Passionfruit, Raspberry Lemonade, Strawberry Banana)')
        expect(pantry_item.barcode).to eq('190912100865')
        expect(pantry_item.img_url).to eq('https://images.openfoodfacts.org/images/products/019/091/210/0865/front_en.3.200.jpg')
      end

      it "redirects to the pantry_item" do
        pantry_item = PantryItem.create! valid_attributes
        patch pantry_item_url(pantry_item), params: { pantry_item: new_attributes }
        pantry_item.reload
        expect(response).to redirect_to(pantry_item_url(pantry_item))
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        pantry_item = PantryItem.create! valid_attributes
        patch pantry_item_url(pantry_item), params: { pantry_item: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested pantry_item" do
      pantry_item = PantryItem.create! valid_attributes
      expect {
        delete pantry_item_url(pantry_item)
      }.to change(PantryItem, :count).by(-1)
    end

    it "redirects to the pantry_items list" do
      pantry_item = PantryItem.create! valid_attributes
      delete pantry_item_url(pantry_item)
      expect(response).to redirect_to(pantry_items_url)
    end
  end

  # Add tests for authentication
  context "when not signed in" do
    before do
      sign_out user
    end

    it "redirects GET /index to login" do
      get pantry_items_url
      expect(response).to redirect_to(new_user_session_url)
    end

    it "redirects POST /create to login" do
      post pantry_items_url, params: { pantry_item: valid_attributes }
      expect(response).to redirect_to(new_user_session_url)
    end
  end
end
