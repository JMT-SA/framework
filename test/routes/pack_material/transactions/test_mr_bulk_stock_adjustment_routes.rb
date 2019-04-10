# frozen_string_literal: true

require File.join(File.expand_path('./../../../', __dir__), 'test_helper_for_routes')

class TestMrBulkStockAdjustmentRoutes < RouteTester

  INTERACTOR = PackMaterialApp::MrBulkStockAdjustmentInteractor

  def test_complete
    authorise_pass!
    ensure_exists!(INTERACTOR)

    url = 'pack_material/transactions/mr_bulk_stock_adjustments/1/edit'
    Framework::RodaRequest.any_instance.stubs(:referer).returns(url)
    INTERACTOR.any_instance.stubs(:complete_bulk_stock_adjustment).returns(ok_response)
    get 'pack_material/transactions/mr_bulk_stock_adjustments/1/complete', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }

    assert last_response.redirect?, "Expected last response to be redirect (status is #{last_response.status}, location is #{last_response.location}) - from: #{caller.first}"
    assert_equal url, last_response.location, "Expected redirect to '#{url}', was '#{last_response.location}' - from: #{caller.first}"
    expect_flash_notice

    INTERACTOR.any_instance.stubs(:complete_bulk_stock_adjustment).returns(bad_response)
    get 'pack_material/transactions/mr_bulk_stock_adjustments/1/complete', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }

    assert last_response.redirect?, "Expected last response to be redirect (status is #{last_response.status}, location is #{last_response.location}) - from: #{caller.first}"
    assert_equal url, last_response.location, "Expected redirect to '#{url}', was '#{last_response.location}' - from: #{caller.first}"
    expect_flash_error
  end

  def test_reopen
    authorise_pass!
    ensure_exists!(INTERACTOR)

    url = 'pack_material/transactions/mr_bulk_stock_adjustments/1/edit'
    Framework::RodaRequest.any_instance.stubs(:referer).returns(url)
    INTERACTOR.any_instance.stubs(:reopen_bulk_stock_adjustment).returns(ok_response)
    get 'pack_material/transactions/mr_bulk_stock_adjustments/1/reopen', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }

    assert last_response.redirect?, "Expected last response to be redirect (status is #{last_response.status}, location is #{last_response.location}) - from: #{caller.first}"
    assert_equal url, last_response.location, "Expected redirect to '#{url}', was '#{last_response.location}' - from: #{caller.first}"
    expect_flash_notice

    INTERACTOR.any_instance.stubs(:reopen_bulk_stock_adjustment).returns(bad_response)
    get 'pack_material/transactions/mr_bulk_stock_adjustments/1/reopen', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }

    assert last_response.redirect?, "Expected last response to be redirect (status is #{last_response.status}, location is #{last_response.location}) - from: #{caller.first}"
    assert_equal url, last_response.location, "Expected redirect to '#{url}', was '#{last_response.location}' - from: #{caller.first}"
    expect_flash_error
  end

  def test_approve
    authorise_pass!
    ensure_exists!(INTERACTOR)

    url = 'pack_material/transactions/mr_bulk_stock_adjustments/1/edit'
    Framework::RodaRequest.any_instance.stubs(:referer).returns(url)
    INTERACTOR.any_instance.stubs(:approve_bulk_stock_adjustment).returns(ok_response)
    get 'pack_material/transactions/mr_bulk_stock_adjustments/1/approve', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }

    assert last_response.redirect?, "Expected last response to be redirect (status is #{last_response.status}, location is #{last_response.location}) - from: #{caller.first}"
    assert_equal url, last_response.location, "Expected redirect to '#{url}', was '#{last_response.location}' - from: #{caller.first}"
    expect_flash_notice

    INTERACTOR.any_instance.stubs(:approve_bulk_stock_adjustment).returns(bad_response)
    get 'pack_material/transactions/mr_bulk_stock_adjustments/1/approve', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }

    assert last_response.redirect?, "Expected last response to be redirect (status is #{last_response.status}, location is #{last_response.location}) - from: #{caller.first}"
    assert_equal url, last_response.location, "Expected redirect to '#{url}', was '#{last_response.location}' - from: #{caller.first}"
    expect_flash_error
  end

  def test_edit
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:assert_permission!).returns(true)
    PackMaterial::Transactions::MrBulkStockAdjustment::Edit.stub(:call, bland_page) do
      get 'pack_material/transactions/mr_bulk_stock_adjustments/1/edit', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_edit_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'pack_material/transactions/mr_bulk_stock_adjustments/1/edit', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_edit_header
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:assert_permission!).returns(true)
    PackMaterial::Transactions::MrBulkStockAdjustment::EditHeader.stub(:call, bland_page) do
      get 'pack_material/transactions/mr_bulk_stock_adjustments/1/edit_header', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_show
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterial::Transactions::MrBulkStockAdjustment::Show.stub(:call, bland_page) do
      get 'pack_material/transactions/mr_bulk_stock_adjustments/1', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_show_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'pack_material/transactions/mr_bulk_stock_adjustments/1', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_update
    authorise_pass!
    ensure_exists!(INTERACTOR)
    row_vals = Hash.new(1)
    INTERACTOR.any_instance.stubs(:update_mr_bulk_stock_adjustment).returns(ok_response(instance: row_vals))
    patch_as_fetch 'pack_material/transactions/mr_bulk_stock_adjustments/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_update_grid
  end

  def test_update_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:update_mr_bulk_stock_adjustment).returns(bad_response)
    PackMaterial::Transactions::MrBulkStockAdjustment::EditHeader.stub(:call, bland_page) do
      patch_as_fetch 'pack_material/transactions/mr_bulk_stock_adjustments/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_json_replace_dialog(has_error: true)
  end

  def test_delete
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:assert_permission!).returns(true)

    INTERACTOR.any_instance.stubs(:delete_mr_bulk_stock_adjustment).returns(ok_response)
    delete_as_fetch 'pack_material/transactions/mr_bulk_stock_adjustments/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_delete_from_grid
  end

  def test_delete_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:assert_permission!).returns(true)

    INTERACTOR.any_instance.stubs(:delete_mr_bulk_stock_adjustment).returns(bad_response)
    delete_as_fetch 'pack_material/transactions/mr_bulk_stock_adjustments/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_error
  end

  def test_new
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterial::Transactions::MrBulkStockAdjustment::New.stub(:call, bland_page) do
      get  'pack_material/transactions/mr_bulk_stock_adjustments/new', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_new_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'pack_material/transactions/mr_bulk_stock_adjustments/new', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_create_remotely
    authorise_pass!
    ensure_exists!(INTERACTOR)
    row_vals = Hash.new(1)
    INTERACTOR.any_instance.stubs(:create_mr_bulk_stock_adjustment).returns(ok_response(instance: row_vals))
    post_as_fetch 'pack_material/transactions/mr_bulk_stock_adjustments', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_add_to_grid(has_notice: true)
  end

  def test_create_remotely_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:create_mr_bulk_stock_adjustment).returns(bad_response)
    PackMaterial::Transactions::MrBulkStockAdjustment::New.stub(:call, bland_page) do
      post_as_fetch 'pack_material/transactions/mr_bulk_stock_adjustments', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_json_replace_dialog
  end

  def test_sku_location_lookup_result
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:get_sku_location_info_ids).returns({ sku_id: 1, location_id: 2 })
    get_as_fetch 'pack_material/transactions/mr_bulk_stock_adjustments/sku_location_lookup_result/1', {}, 'rack.session' => { user_id: 1 }

    assert last_response.body.include?('change_select_value')
    assert last_response.body.include?('mr_bulk_stock_adjustment_item_mr_sku_id')
    assert last_response.body.include?('mr_bulk_stock_adjustment_item_location_id')
    assert last_response.ok?
    assert has_json_response
  end

  def test_link_mr_skus
    authorise_pass!
    ensure_exists!(INTERACTOR)
    Framework.any_instance.stubs(:multiselect_grid_choices).returns(true)
    INTERACTOR.any_instance.stubs(:link_mr_skus).returns(ok_response)
    post_as_fetch 'pack_material/transactions/mr_bulk_stock_adjustments/link_mr_skus/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }

    assert last_response.body.include?('notice')
    assert last_response.ok?, "Expected last response to be OK (status is #{last_response.status}) - from: #{caller.first}"
    assert has_json_response, "Expected JSON headers, got '#{last_response.content_type}' - from: #{caller.first}"
  end

  def test_link_locations
    authorise_pass!
    ensure_exists!(INTERACTOR)
    Framework.any_instance.stubs(:multiselect_grid_choices).returns(true)
    INTERACTOR.any_instance.stubs(:link_locations).returns(ok_response)
    post_as_fetch 'pack_material/transactions/mr_bulk_stock_adjustments/link_locations/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }

    assert last_response.body.include?('notice')
    assert last_response.ok?, "Expected last response to be OK (status is #{last_response.status}) - from: #{caller.first}"
    assert has_json_response, "Expected JSON headers, got '#{last_response.content_type}' - from: #{caller.first}"
  end
end
