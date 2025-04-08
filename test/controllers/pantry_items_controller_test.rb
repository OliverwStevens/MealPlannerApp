require "test_helper"

class PantryItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @pantry_item = pantry_items(:one)
  end

  test "should get index" do
    get pantry_items_url
    assert_response :success
  end

  test "should get new" do
    get new_pantry_item_url
    assert_response :success
  end

  test "should create pantry_item" do
    assert_difference("PantryItem.count") do
      post pantry_items_url, params: { pantry_item: { barcode: @pantry_item.barcode, name: @pantry_item.name, quantity: @pantry_item.quantity, user_id: @pantry_item.user_id } }
    end

    assert_redirected_to pantry_item_url(PantryItem.last)
  end

  test "should show pantry_item" do
    get pantry_item_url(@pantry_item)
    assert_response :success
  end

  test "should get edit" do
    get edit_pantry_item_url(@pantry_item)
    assert_response :success
  end

  test "should update pantry_item" do
    patch pantry_item_url(@pantry_item), params: { pantry_item: { barcode: @pantry_item.barcode, name: @pantry_item.name, quantity: @pantry_item.quantity, user_id: @pantry_item.user_id } }
    assert_redirected_to pantry_item_url(@pantry_item)
  end

  test "should destroy pantry_item" do
    assert_difference("PantryItem.count", -1) do
      delete pantry_item_url(@pantry_item)
    end

    assert_redirected_to pantry_items_url
  end
end
