require "application_system_test_case"

class PantryItemsTest < ApplicationSystemTestCase
  setup do
    @pantry_item = pantry_items(:one)
  end

  test "visiting the index" do
    visit pantry_items_url
    assert_selector "h1", text: "Pantry items"
  end

  test "should create pantry item" do
    visit pantry_items_url
    click_on "New pantry item"

    fill_in "Barcode", with: @pantry_item.barcode
    fill_in "Name", with: @pantry_item.name
    fill_in "Quantity", with: @pantry_item.quantity
    fill_in "User", with: @pantry_item.user_id
    click_on "Create Pantry item"

    assert_text "Pantry item was successfully created"
    click_on "Back"
  end

  test "should update Pantry item" do
    visit pantry_item_url(@pantry_item)
    click_on "Edit this pantry item", match: :first

    fill_in "Barcode", with: @pantry_item.barcode
    fill_in "Name", with: @pantry_item.name
    fill_in "Quantity", with: @pantry_item.quantity
    fill_in "User", with: @pantry_item.user_id
    click_on "Update Pantry item"

    assert_text "Pantry item was successfully updated"
    click_on "Back"
  end

  test "should destroy Pantry item" do
    visit pantry_item_url(@pantry_item)
    click_on "Destroy this pantry item", match: :first

    assert_text "Pantry item was successfully destroyed"
  end
end
