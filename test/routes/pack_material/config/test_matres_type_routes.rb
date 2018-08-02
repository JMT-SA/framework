# frozen_string_literal: true

require File.join(File.expand_path('./../../../', __dir__), 'test_helper_for_routes')

class TestMatresTypeRoutes < RouteTester

  INTERACTOR = PackMaterialApp::ConfigInteractor

  def test_edit
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterial::Config::MatresType::Edit.stub(:call, bland_page) do
      get 'pack_material/config/material_resource_types/1/edit', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_edit_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'pack_material/config/material_resource_types/1/edit', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_show
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterial::Config::MatresType::Show.stub(:call, bland_page) do
      get 'pack_material/config/material_resource_types/1', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_show_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'pack_material/config/material_resource_types/1', {}, 'rack.session' => { user_id: 1 }
    refute last_response.ok?
    assert_match(/permission/i, last_response.body)
  end

  def test_update
    authorise_pass!
    ensure_exists!(INTERACTOR)
    row_vals = Hash.new(1)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:update_matres_type).returns(ok_response(instance: row_vals))
    patch 'pack_material/config/material_resource_types/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_update_grid
  end

  def test_update_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:update_matres_type).returns(bad_response)
    PackMaterial::Config::MatresType::Edit.stub(:call, bland_page) do
      patch 'pack_material/config/material_resource_types/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_json_replace_dialog(has_error: true)
  end

  def test_delete
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:delete_matres_type).returns(ok_response)
    delete 'pack_material/config/material_resource_types/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_delete_from_grid
  end
  #
  # def test_delete_fail
  #   authorise_pass!
  #   ensure_exists!(INTERACTOR)
  #   PackMaterialApp::ConfigInteractor.any_instance.stubs(:delete_matres_type).returns(bad_response)
  #   delete 'pack_material/config/material_resource_types/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
  #   expect_bad_redirect
  # end

  def test_new
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterial::Config::MatresType::New.stub(:call, bland_page) do
      get  'pack_material/config/material_resource_types/new', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_new_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'pack_material/config/material_resource_types/new', {}, 'rack.session' => { user_id: 1 }
    refute last_response.ok?
    assert_match(/permission/i, last_response.body)
  end

  def test_create
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:create_matres_type).returns(ok_response)
    post 'pack_material/config/material_resource_types', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_flash_notice
    expect_ok_redirect
  end

  def test_create_remotely
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:create_matres_type).returns(ok_response)
    post_as_fetch 'pack_material/config/material_resource_types', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_flash_notice
    expect_ok_json_redirect
  end

  def test_create_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:create_matres_type).returns(bad_response)
    PackMaterial::Config::MatresType::New.stub(:call, bland_page) do
      post_as_fetch 'pack_material/config/material_resource_types', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_bad_page

    PackMaterial::Config::MatresType::New.stub(:call, bland_page) do
      post 'pack_material/config/material_resource_types', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_bad_redirect(url: '/pack_material/config/material_resource_types/new')
  end

  def test_create_remotely_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:create_matres_type).returns(bad_response)
    PackMaterial::Config::MatresType::New.stub(:call, bland_page) do
      post_as_fetch 'pack_material/config/material_resource_types', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_json_replace_dialog
  end

  def test_new_unit
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterial::Config::MatresType::Unit.stub(:call, bland_page) do
      get  'pack_material/config/material_resource_types/1/unit/new', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_new_unit_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'pack_material/config/material_resource_types/1/unit/new', {}, 'rack.session' => { user_id: 1 }
    refute last_response.ok?
    assert_match(/permission/i, last_response.body)
  end

  def test_create_unit
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:add_a_matres_unit).returns(ok_response)
    post 'pack_material/config/material_resource_types/1/unit', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_flash_notice
    expect_ok_redirect
  end

  def test_create_unit_remotely
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:add_a_matres_unit).returns(ok_response)
    post_as_fetch 'pack_material/config/material_resource_types/1/unit', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_flash_notice
    expect_ok_json_redirect
  end

  def test_create_unit_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:add_a_matres_unit).returns(bad_response)
    PackMaterial::Config::MatresType::Unit.stub(:call, bland_page) do
      post_as_fetch 'pack_material/config/material_resource_types/1/unit', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_bad_page

    PackMaterial::Config::MatresType::Unit.stub(:call, bland_page) do
      post 'pack_material/config/material_resource_types/1/unit', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_bad_redirect(url: '/pack_material/config/material_resource_types/1/unit/new')
  end

  def test_create_unit_remotely_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:add_a_matres_unit).returns(bad_response)
    PackMaterial::Config::MatresType::Unit.stub(:call, bland_page) do
      post_as_fetch 'pack_material/config/material_resource_types/1/unit', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_json_replace_dialog
  end

end
