# frozen_string_literal: true

require File.join(File.expand_path('./../../../', __dir__), 'test_helper_for_routes')

class TestMrPurchaseOrderRoutes < RouteTester

  INTERACTOR = PackMaterialApp::MrPurchaseOrderInteractor

  def test_edit
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterial::Replenish::MrPurchaseOrder::Edit.stub(:call, bland_page) do
      get 'pack_material/replenish/mr_purchase_orders/1/edit', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_edit_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'pack_material/replenish/mr_purchase_orders/1/edit', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_update
    authorise_pass!
    ensure_exists!(INTERACTOR)
    row_vals = Hash.new(1)
    INTERACTOR.any_instance.stubs(:update_mr_purchase_order).returns(ok_response(instance: row_vals))
    patch_as_fetch 'pack_material/replenish/mr_purchase_orders/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }

    url = '/pack_material/replenish/mr_purchase_orders/1/edit'
    assert last_response.redirect?, "Expected last response to be redirect (status is #{last_response.status}, location is #{last_response.location}) - from: #{caller.first}"
    assert_equal url, last_response.location, "Expected redirect to '#{url}', was '#{last_response.location}' - from: #{caller.first}"
  end

  def test_update_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:update_mr_purchase_order).returns(bad_response)
    PackMaterial::Replenish::MrPurchaseOrder::Edit.stub(:call, bland_page) do
      patch_as_fetch 'pack_material/replenish/mr_purchase_orders/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_json_replace_dialog(has_error: true)
  end

  def test_delete
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:delete_mr_purchase_order).returns(ok_response)
    delete_as_fetch 'pack_material/replenish/mr_purchase_orders/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_delete_from_grid
  end

  def test_delete_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:delete_mr_purchase_order).returns(bad_response)
    delete_as_fetch 'pack_material/replenish/mr_purchase_orders/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_error
  end

  def test_preselect
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterial::Replenish::MrPurchaseOrder::Preselect.stub(:call, bland_page) do
      get  'pack_material/replenish/mr_purchase_orders/preselect', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_preselect_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'pack_material/replenish/mr_purchase_orders/preselect', {}, 'rack.session' => { user_id: 1 }
    refute last_response.ok?
    assert_match(/permission/i, last_response.body)
  end

  def test_new
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterial::Replenish::MrPurchaseOrder::New.stub(:call, bland_page) do
      get  'pack_material/replenish/mr_purchase_orders/new/1', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_new_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'pack_material/replenish/mr_purchase_orders/new/1', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_new_post
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterial::Replenish::MrPurchaseOrder::New.stub(:call, bland_page(content: 'OK')) do
      post 'pack_material/replenish/mr_purchase_orders/new', { mr_purchase_order: { supplier_id: 1 } }, 'rack.session' => { user_id: 1 }
    end
    expect_ok_redirect(url: '/pack_material/replenish/mr_purchase_orders/new/1')
  end

  def test_new_post_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    post 'pack_material/replenish/mr_purchase_orders/new', { mr_purchase_order: { supplier_id: 1 } }, 'rack.session' => { user_id: 1 }

    refute last_response.ok?
    assert_match(/permission/i, last_response.body)
  end

  def test_create
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:create_mr_purchase_order).returns(success_response('ok', OpenStruct.new(id: 1)))
    post 'pack_material/replenish/mr_purchase_orders', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }

    url = '/pack_material/replenish/mr_purchase_orders/1/edit'
    assert last_response.redirect?, "Expected last response to be redirect (status is #{last_response.status}, location is #{last_response.location}) - from: #{caller.first}"
    assert_equal url, last_response.location, "Expected redirect to '#{url}', was '#{last_response.location}' - from: #{caller.first}"
  end

  def test_create_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:create_mr_purchase_order).returns(bad_response)
    PackMaterial::Replenish::MrPurchaseOrder::New.stub(:call, bland_page) do
      post 'pack_material/replenish/mr_purchase_orders', { mr_purchase_order: { supplier_id: 1 } }, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end

    url = '/pack_material/replenish/mr_purchase_orders/new/1'
    assert last_response.redirect?, "Expected last response to be redirect (status is #{last_response.status}, location is #{last_response.location}) - from: #{caller.first}"
    assert_equal url, last_response.location, "Expected redirect to '#{url}', was '#{last_response.location}' - from: #{caller.first}"
  end
end
