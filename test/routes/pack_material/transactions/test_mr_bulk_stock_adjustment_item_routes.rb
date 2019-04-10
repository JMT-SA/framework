# frozen_string_literal: true

require File.join(File.expand_path('./../../../', __dir__), 'test_helper_for_routes')

class TestMrBulkStockAdjustmentItemRoutes < RouteTester

  INTERACTOR = PackMaterialApp::MrBulkStockAdjustmentItemInteractor
  PARENT_INTERACTOR = PackMaterialApp::MrBulkStockAdjustmentInteractor

  def test_show
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterial::Transactions::MrBulkStockAdjustmentItem::Show.stub(:call, bland_page) do
      get 'pack_material/transactions/mr_bulk_stock_adjustment_items/1', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_show_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'pack_material/transactions/mr_bulk_stock_adjustment_items/1', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_delete
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:assert_permission!).returns(true)
    INTERACTOR.any_instance.stubs(:delete_mr_bulk_stock_adjustment_item).returns(ok_response)
    delete_as_fetch 'pack_material/transactions/mr_bulk_stock_adjustment_items/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_delete_from_grid
  end

  def test_delete_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:assert_permission!).returns(true)
    INTERACTOR.any_instance.stubs(:delete_mr_bulk_stock_adjustment_item).returns(bad_response)
    delete_as_fetch 'pack_material/transactions/mr_bulk_stock_adjustment_items/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_error
  end

  def test_new
    authorise_pass!
    ensure_exists!(INTERACTOR)
    ensure_exists!(PARENT_INTERACTOR)
    PackMaterial::Transactions::MrBulkStockAdjustmentItem::New.stub(:call, bland_page) do
      get 'pack_material/transactions/mr_bulk_stock_adjustments/1/mr_bulk_stock_adjustment_items/new', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_new_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    ensure_exists!(PARENT_INTERACTOR)
    get 'pack_material/transactions/mr_bulk_stock_adjustments/1/mr_bulk_stock_adjustment_items/new', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_create_remotely
    authorise_pass!
    ensure_exists!(INTERACTOR)
    ensure_exists!(PARENT_INTERACTOR)
    row_vals = Hash.new(1)
    INTERACTOR.any_instance.stubs(:create_mr_bulk_stock_adjustment_item).returns(ok_response(instance: row_vals))
    post_as_fetch 'pack_material/transactions/mr_bulk_stock_adjustments/1/mr_bulk_stock_adjustment_items', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }

    assert last_response.body.include?('change_select_value')
    assert last_response.body.include?('mr_bulk_stock_adjustment_item_mr_sku_id')
    assert last_response.body.include?('mr_bulk_stock_adjustment_item_location_id')
    assert last_response.body.include?('replace_list_items')
    assert last_response.body.include?('mr_bulk_stock_adjustment_item_list_items')
    assert last_response.body.include?('clear_form_validation')
    assert last_response.body.include?('new_bsa_item')
    assert last_response.ok?
    assert has_json_response
  end

  def test_create_remotely_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    ensure_exists!(PARENT_INTERACTOR)
    INTERACTOR.any_instance.stubs(:create_mr_bulk_stock_adjustment_item).returns(bad_response)
    PackMaterial::Transactions::MrBulkStockAdjustmentItem::New.stub(:call, bland_page) do
      post_as_fetch 'pack_material/transactions/mr_bulk_stock_adjustments/1/mr_bulk_stock_adjustment_items', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_json_replace_dialog
  end

  def test_inline_save
    authorise_pass!
    ensure_exists!(INTERACTOR)

    INTERACTOR.any_instance.stubs(:inline_update).returns(ok_response)
    INTERACTOR.any_instance.stubs(:mr_bulk_stock_adjustment_item).returns(ok_response(instance: OpenStruct.new(mr_bulk_stock_adjustment_id: 1)))
    INTERACTOR.any_instance.stubs(:can_complete).returns(ok_response)
    post_as_fetch 'pack_material/transactions/mr_bulk_stock_adjustment_items/1/inline_save', {}, 'rack.session' => { user_id: 1 }
    assert last_response.body.include?('notice')
    assert last_response.body.include?('show_element')
    assert last_response.body.include?('mr_bulk_stock_adjustments_complete_button')

    INTERACTOR.any_instance.stubs(:can_complete).returns(bad_response)
    post_as_fetch 'pack_material/transactions/mr_bulk_stock_adjustment_items/1/inline_save', {}, 'rack.session' => { user_id: 1 }
    assert last_response.body.include?('notice')
    assert last_response.body.include?('hide_element')
    assert last_response.body.include?('mr_bulk_stock_adjustments_complete_button')

    INTERACTOR.any_instance.stubs(:inline_update).returns(bad_response)
    post_as_fetch 'pack_material/transactions/mr_bulk_stock_adjustment_items/1/inline_save', {}, 'rack.session' => { user_id: 1 }
    expect_json_error
  end

  def test_inline_save_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    post_as_fetch 'pack_material/transactions/mr_bulk_stock_adjustment_items/1/inline_save', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end
end