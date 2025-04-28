require 'rails_helper'

RSpec.describe User, type: :model do
  it "returns the full name" do
    user = build(:user, first_name: "Chipper", last_name: "Roe")

    expect(user.name).to eq ("Chipper Roe")
  end
end
