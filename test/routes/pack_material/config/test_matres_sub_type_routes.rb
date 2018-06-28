# frozen_string_literal: true

require File.join(File.expand_path('./../../../', __dir__), 'test_helper_for_routes')

class TestMatresSubTypeRoutes < RouteTester

  INTERACTOR = PackMaterialApp::ConfigInteractor

  def test_edit
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterial::Config::MatresSubType::Edit.stub(:call, bland_page) do
      get 'pack_material/config/material_resource_sub_types/1/edit', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_edit_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'pack_material/config/material_resource_sub_types/1/edit', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_show
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterial::Config::MatresSubType::Show.stub(:call, bland_page) do
      get 'pack_material/config/material_resource_sub_types/1', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_show_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'pack_material/config/material_resource_sub_types/1', {}, 'rack.session' => { user_id: 1 }
    refute last_response.ok?
    assert_match(/permission/i, last_response.body)
  end

  def test_update
    authorise_pass!
    ensure_exists!(INTERACTOR)
    row_vals = Hash.new(1)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:update_matres_sub_type).returns(ok_response(instance: row_vals))
    patch 'pack_material/config/material_resource_sub_types/1', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    expect_json_update_grid
  end

  def test_update_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:update_matres_sub_type).returns(bad_response)
    PackMaterial::Config::MatresSubType::Edit.stub(:call, bland_page) do
      patch 'pack_material/config/material_resource_sub_types/1', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    end
    expect_json_replace_dialog(has_error: true)
  end

  def test_delete
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:delete_matres_sub_type).returns(ok_response)
    delete 'pack_material/config/material_resource_sub_types/1', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    expect_json_delete_from_grid
  end

  def test_new
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterial::Config::MatresSubType::New.stub(:call, bland_page) do
      get  'pack_material/config/material_resource_sub_types/new', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_new_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'pack_material/config/material_resource_sub_types/new', {}, 'rack.session' => { user_id: 1 }
    refute last_response.ok?
    assert_match(/permission/i, last_response.body)
  end

  def test_create
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:create_matres_sub_type).returns(ok_response)
    post 'pack_material/config/material_resource_sub_types', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    expect_ok_redirect
  end

  def test_create_remotely
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:create_matres_sub_type).returns(ok_response)
    post_as_fetch 'pack_material/config/material_resource_sub_types', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    expect_ok_json_redirect
  end

  def test_create_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:create_matres_sub_type).returns(bad_response)
    PackMaterial::Config::MatresSubType::New.stub(:call, bland_page) do
      post_as_fetch 'pack_material/config/material_resource_sub_types', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    end
    expect_bad_page

    PackMaterial::Config::MatresSubType::New.stub(:call, bland_page) do
      post 'pack_material/config/material_resource_sub_types', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    end
    expect_bad_redirect(url: '/pack_material/config/material_resource_sub_types/new')
  end

  def test_create_remotely_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:create_matres_sub_type).returns(bad_response)
    PackMaterial::Config::MatresSubType::New.stub(:call, bland_page) do
      post_as_fetch 'pack_material/config/material_resource_sub_types', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    end
    expect_json_replace_dialog
  end

  def test_product_columns
    authorise_pass!
    ensure_exists!(INTERACTOR)

    PackMaterialApp::ConfigRepo.any_instance.stubs(:find_matres_sub_type).returns( OpenStruct.new({ product_column_ids: [1,2,3] }) )
    get 'pack_material/config/material_resource_sub_types/1/product_columns', {}, 'rack.session' => { user_id: 1 }
    url = '/list/material_resource_product_columns/with_params?key=standard&product_column_ids=[1, 2, 3]'
    assert last_response.redirect?
    assert_equal url, header_location
    follow_redirect!
    assert last_response.ok?

    PackMaterialApp::ConfigRepo.any_instance.stubs(:find_matres_sub_type).returns(OpenStruct.new({ product_column_ids: nil }))
    get 'pack_material/config/material_resource_sub_types/1/product_columns', {}, 'rack.session' => { user_id: 1 }
    url = '/list/material_resource_sub_types'
    # TODO: How do I assert that the flash error message was shown and updated?
    assert last_response.redirect?
    assert_equal url, header_location
    follow_redirect!
    assert last_response.ok?
  end

  def test_config_edit
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterial::Config::MatresSubType::Config.stub(:call, bland_page) do
      get 'pack_material/config/material_resource_sub_types/1/config/edit', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_config_edit_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'pack_material/config/material_resource_sub_types/1/config/edit', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_config_update
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:update_matres_config).returns(ok_response)
    patch 'pack_material/config/material_resource_sub_types/1/config', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    expect_json_response
    assert last_response.ok?
    assert last_response.body.include?('notice')
  end

  def test_config_update_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:update_matres_config).returns(bad_response)
    PackMaterial::Config::MatresSubType::Config.stub(:call, bland_page) do
      patch 'pack_material/config/material_resource_sub_types/1/config', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    end
    expect_json_response
    refute last_response.ok?
    assert last_response.body.include?('error')
  end

  def test_prod_code_config
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:update_product_code_configuration).returns(ok_response)
    post 'pack_material/config/material_resource_sub_types/1/update_product_code_configuration', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    expect_ok_redirect
  end

  def test_prod_code_config_remotely
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:update_product_code_configuration).returns(ok_response)
    post_as_fetch 'pack_material/config/material_resource_sub_types/1/update_product_code_configuration', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    expect_ok_json_redirect
  end

  def test_prod_code_config_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:update_product_code_configuration).returns(bad_response)
    PackMaterial::Config::MatresSubType::Config.stub(:call, bland_page) do
      post_as_fetch 'pack_material/config/material_resource_sub_types/1/update_product_code_configuration', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
      end
    expect_bad_redirect(url: '/pack_material/config/material_resource_sub_types/1/config/edit')
    # expect_bad_page

    PackMaterial::Config::MatresSubType::Config.stub(:call, bland_page) do
      post 'pack_material/config/material_resource_sub_types/1/update_product_code_configuration', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    end
    expect_bad_redirect(url: '/pack_material/config/material_resource_sub_types/1/config/edit')
  end

  def test_prod_code_config_remotely_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:update_product_code_configuration).returns(bad_response)
    PackMaterial::Config::MatresSubType::Config.stub(:call, bland_page) do
      post_as_fetch 'pack_material/config/material_resource_sub_types/1/update_product_code_configuration', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    end
    expect_bad_redirect(url: '/pack_material/config/material_resource_sub_types/1/config/edit')
    # expect_json_replace_dialog
  end

  def test_link_product_columns
    authorise_pass!
    ensure_exists!(INTERACTOR)

    PackMaterialApp::ConfigInteractor.any_instance.stubs(:chosen_product_columns).returns(ok_response(instance: OpenStruct.new(code: [1,2,3])))
    post 'pack_material/config/link_product_columns', { selection: { list: '1,2,3' } }, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    expect_json_response
    assert last_response.ok?
    assert last_response.body.include?('actions')
    assert last_response.body.include?('replace_input_value')
    assert last_response.body.include?('replace_multi_options')
    assert last_response.body.include?('Re-assigned product columns')

    PackMaterialApp::ConfigInteractor.any_instance.stubs(:chosen_product_columns).returns(ok_response(instance: OpenStruct.new(code: [1,2,3])))
    post_as_fetch 'pack_material/config/link_product_columns', { selection: { list: '1,2,3' } }, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    expect_json_response
    assert last_response.ok?
    assert last_response.body.include?('actions')
    assert last_response.body.include?('replace_input_value')
    assert last_response.body.include?('replace_multi_options')
    assert last_response.body.include?('Re-assigned product columns')
  end
end
