require 'rails_helper'

RSpec.describe PantryItem, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:barcode) }
    it { should validate_presence_of(:user_id) }

    context 'when barcode is present' do
      it 'is valid with a barcode and user_id' do
        user = create(:user)
        pantry_item = build(:pantry_item, barcode: '1234567890', user: user)
        expect(pantry_item).to be_valid
      end
    end

    context 'when barcode is missing' do
      it 'is invalid without a barcode' do
        user = create(:user)
        pantry_item = build(:pantry_item, barcode: nil, user: user)
        expect(pantry_item).not_to be_valid
        expect(pantry_item.errors[:barcode]).to include("can't be blank")
      end
    end

    context 'when user_id is missing' do
      it 'is invalid without a user_id' do
        pantry_item = build(:pantry_item, barcode: '1234567890', user: nil)
        expect(pantry_item).not_to be_valid
        expect(pantry_item.errors[:user]).to include("must exist")
      end
    end
  end
end
