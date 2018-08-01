# frozen_string_literal: true

require File.join(File.expand_path('./../../../', __dir__), 'test_helper_for_routes')

class TestPmProductRoutes < RouteTester
  INTERACTOR = PackMaterialApp::PmProductInteractor

  def test_edit
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterial::Config::PmProduct::Edit.stub(:call, bland_page) do
      get 'pack_material/config/pack_material_products/1/edit', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_edit_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'pack_material/config/pack_material_products/1/edit', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_show
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterial::Config::PmProduct::Show.stub(:call, bland_page) do
      get 'pack_material/config/pack_material_products/1', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_show_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'pack_material/config/pack_material_products/1', {}, 'rack.session' => { user_id: 1 }
    refute last_response.ok?
    assert_match(/permission/i, last_response.body)
  end

  def test_update
    authorise_pass!
    ensure_exists!(INTERACTOR)
    row_vals = Hash.new(1)
    PackMaterialApp::PmProductInteractor.any_instance.stubs(:update_pm_product).returns(ok_response(instance: row_vals))
    patch 'pack_material/config/pack_material_products/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_update_grid
  end

  def test_update_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::PmProductInteractor.any_instance.stubs(:update_pm_product).returns(bad_response)
    PackMaterial::Config::PmProduct::Edit.stub(:call, bland_page) do
      patch 'pack_material/config/pack_material_products/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_json_replace_dialog(has_error: true)
  end

  def test_delete
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::PmProductInteractor.any_instance.stubs(:delete_pm_product).returns(ok_response)
    delete 'pack_material/config/pack_material_products/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_delete_from_grid
  end

  def test_delete_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::PmProductInteractor.any_instance.stubs(:delete_pm_product).returns(bad_response)
    delete 'pack_material/config/pack_material_products/1', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    expect_bad_redirect
  end

  def test_preselect
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterial::Config::PmProduct::Preselect.stub(:call, bland_page) do
      get  'pack_material/config/pack_material_products/preselect', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_preselect_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'pack_material/config/pack_material_products/preselect', {}, 'rack.session' => { user_id: 1 }
    refute last_response.ok?
    assert_match(/permission/i, last_response.body)
  end

  def test_new
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterial::Config::PmProduct::New.stub(:call, bland_page) do
      get  'pack_material/config/pack_material_products/new/1', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_new_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'pack_material/config/pack_material_products/new/1', {}, 'rack.session' => { user_id: 1 }
    refute last_response.ok?
    assert_match(/permission/i, last_response.body)
  end

  def test_new_post
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterial::Config::PmProduct::New.stub(:call, bland_page(content: 'OK')) do
      post 'pack_material/config/pack_material_products/new', { pm_product: {material_resource_sub_type_id: 1 } }, 'rack.session' => { user_id: 1 }
    end
    expect_ok_redirect(url: '/pack_material/config/pack_material_products/new/1')
  end

  def test_new_post_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    post 'pack_material/config/pack_material_products/new', { pm_product: {material_resource_sub_type_id: 1 } }, 'rack.session' => { user_id: 1 }

    refute last_response.ok?
    assert_match(/permission/i, last_response.body)
  end

  def test_create
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::PmProductInteractor.any_instance.stubs(:create_pm_product).returns(ok_response)
    post 'pack_material/config/pack_material_products', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_ok_redirect
  end

  def test_create_remotely
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::PmProductInteractor.any_instance.stubs(:create_pm_product).returns(ok_response)
    post_as_fetch 'pack_material/config/pack_material_products', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_ok_json_redirect
  end

  def test_create_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::PmProductInteractor.any_instance.stubs(:create_pm_product).returns(bad_response)
    PackMaterial::Config::PmProduct::New.stub(:call, bland_page) do
      post_as_fetch 'pack_material/config/pack_material_products', { pm_product: {material_resource_sub_type: 1 } }, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_bad_page

    PackMaterial::Config::PmProduct::New.stub(:call, bland_page) do
      post 'pack_material/config/pack_material_products', { pm_product: {material_resource_sub_type_id: 1 } }, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_bad_redirect(url: '/pack_material/config/pack_material_products/new/1')
  end

  def test_create_remotely_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::PmProductInteractor.any_instance.stubs(:create_pm_product).returns(bad_response)
    PackMaterial::Config::PmProduct::New.stub(:call, bland_page) do
      post_as_fetch 'pack_material/config/pack_material_products', { pm_product: {material_resource_sub_type: 1 } }, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_json_replace_dialog
  end

  def test_clone
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterial::Config::PmProduct::Clone.stub(:call, bland_page) do
      get 'pack_material/config/pack_material_products/1/clone', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_clone_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'pack_material/config/pack_material_products/1/clone', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_clone_post
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::PmProductInteractor.any_instance.stubs(:clone_pm_product).returns(ok_response)
    post 'pack_material/config/pack_material_products/clone/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_ok_redirect

    post_as_fetch 'pack_material/config/pack_material_products/clone/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_ok_json_redirect
  end

  def test_clone_post_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::PmProductInteractor.any_instance.stubs(:clone_pm_product).returns(bad_response)
    PackMaterial::Config::PmProduct::Clone.stub(:call, bland_page) do
      post 'pack_material/config/pack_material_products/clone/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    assert last_response.redirect?
    assert_equal '/pack_material/config/pack_material_products/1/clone', header_location
    refute last_response.ok?

    PackMaterial::Config::PmProduct::Clone.stub(:call, bland_page) do
      post_as_fetch 'pack_material/config/pack_material_products/clone/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_json_replace_dialog
  end
end
