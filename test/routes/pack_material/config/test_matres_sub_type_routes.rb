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
    patch 'pack_material/config/material_resource_sub_types/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_update_grid
  end

  def test_update_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:update_matres_sub_type).returns(bad_response)
    PackMaterial::Config::MatresSubType::Edit.stub(:call, bland_page) do
      patch 'pack_material/config/material_resource_sub_types/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_json_replace_dialog(has_error: true)
  end

  def test_delete
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:delete_matres_sub_type).returns(ok_response)
    delete 'pack_material/config/material_resource_sub_types/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
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
    post 'pack_material/config/material_resource_sub_types', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_flash_notice
    expect_ok_redirect
  end

  def test_create_remotely
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:create_matres_sub_type).returns(ok_response)
    post_as_fetch 'pack_material/config/material_resource_sub_types', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_flash_notice
    expect_ok_json_redirect
  end

  def test_create_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:create_matres_sub_type).returns(bad_response)
    PackMaterial::Config::MatresSubType::New.stub(:call, bland_page) do
      post_as_fetch 'pack_material/config/material_resource_sub_types', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_bad_page

    PackMaterial::Config::MatresSubType::New.stub(:call, bland_page) do
      post 'pack_material/config/material_resource_sub_types', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_bad_redirect(url: '/pack_material/config/material_resource_sub_types/new')
  end

  def test_create_remotely_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:create_matres_sub_type).returns(bad_response)
    PackMaterial::Config::MatresSubType::New.stub(:call, bland_page) do
      post_as_fetch 'pack_material/config/material_resource_sub_types', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_json_replace_dialog
  end

  def test_product_columns
    authorise_pass!
    ensure_exists!(INTERACTOR)

    PackMaterialApp::ConfigRepo.any_instance.stubs(:find_matres_sub_type).returns( OpenStruct.new({ product_column_ids: [1,2,3] }) )
    # Change this to use something like the following: (Stub the interactor rather than the repo)
    # INTERACTOR.any_instance.stubs(:whatever).returns(ok_response)
    get 'pack_material/config/material_resource_sub_types/1/product_columns', {}, 'rack.session' => { user_id: 1 }
    url = '/list/material_resource_product_column_master_list_items/with_params?key=standard&sub_type_id=1&product_column_ids=[1, 2, 3]'
    assert last_response.redirect?
    assert_equal url, last_response.location
    follow_redirect!
    assert last_response.ok?
    # Change the 4 lines above to this: (If you stub the interactor, the has_dummy_content can be removed.)
    # expect_ok_redirect(url: url, has_dummy_content: false)


    PackMaterialApp::ConfigRepo.any_instance.stubs(:find_matres_sub_type).returns(OpenStruct.new({ product_column_ids: nil }))
    get 'pack_material/config/material_resource_sub_types/1/product_columns', {}, 'rack.session' => { user_id: 1 }
    url = '/list/material_resource_sub_types'
    expect_flash_error('No product columns selected, please see config.')

    assert last_response.redirect?
    assert_equal url, last_response.location
    follow_redirect!
    assert last_response.ok?
  end

  def test_master_list_items_edit
    # edit
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterial::Config::MatresMasterListItem::Edit.stub(:call, bland_page) do
      get 'pack_material/config/material_resource_sub_types/1/material_resource_master_list_items/1/edit', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page

    # edit_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'pack_material/config/material_resource_sub_types/1/material_resource_master_list_items/1/edit', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_master_list_items_update
    # update
    authorise_pass!
    ensure_exists!(INTERACTOR)
    row_vals = Hash.new(1)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:update_matres_master_list_item).returns(ok_response(instance: row_vals))
    patch 'pack_material/config/material_resource_sub_types/1/material_resource_master_list_items/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_update_grid

    # update fail
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:update_matres_master_list_item).returns(bad_response)
    PackMaterial::Config::MatresMasterListItem::Edit.stub(:call, bland_page) do
      patch 'pack_material/config/material_resource_sub_types/1/material_resource_master_list_items/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_json_replace_dialog(has_error: true)
  end

  def test_preselect
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterial::Config::MatresMasterListItem::Preselect.stub(:call, bland_page) do
      get  'pack_material/config/material_resource_sub_types/1/material_resource_master_list_items/preselect', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_preselect_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'pack_material/config/material_resource_sub_types/1/material_resource_master_list_items/preselect', {}, 'rack.session' => { user_id: 1 }
    refute last_response.ok?
    assert_match(/permission/i, last_response.body)
  end

  def test_master_list_items_new
    ensure_exists!(INTERACTOR)
    # new
    authorise_pass!
    PackMaterial::Config::MatresMasterListItem::New.stub(:call, bland_page) do
      get  'pack_material/config/material_resource_sub_types/1/material_resource_master_list_items/new/1', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page

    # new fail
    authorise_fail!
    get  'pack_material/config/material_resource_sub_types/1/material_resource_master_list_items/new/1', {}, 'rack.session' => { user_id: 1 }
    refute last_response.ok?
    assert_match(/permission/i, last_response.body)
  end

  def test_new_post
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterial::Config::MatresMasterListItem::New.stub(:call, bland_page(content: 'OK')) do
      post 'pack_material/config/material_resource_sub_types/1/material_resource_master_list_items/new', { matres_master_list_item: {material_resource_product_column_id: 1 } }, 'rack.session' => { user_id: 1 }
    end
    expect_ok_redirect(url: '/pack_material/config/material_resource_sub_types/1/material_resource_master_list_items/new/1')
  end

  def test_new_post_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    post 'pack_material/config/material_resource_sub_types/1/material_resource_master_list_items/new', { matres_master_list_item: {material_resource_product_column_id: 1 } }, 'rack.session' => { user_id: 1 }

    refute last_response.ok?
    assert_match(/permission/i, last_response.body)
  end

  def test_master_list_items_create
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:create_matres_master_list_item).returns(ok_response)

    # remotely
    post_as_fetch 'pack_material/config/material_resource_sub_types/1/material_resource_master_list_items', { matres_master_list_item: { material_resource_product_column_id: 1 }}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_response
    assert last_response.ok?
    assert last_response.body.include?('actions')
    assert last_response.body.include?('replace_input_value')
    assert last_response.body.include?('replace_list_items')
    assert last_response.body.include?('Added new item')
  end

  def test_master_list_items_create_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:create_matres_master_list_item).returns(bad_response)
    PackMaterial::Config::MatresMasterListItem::New.stub(:call, bland_page) do
      post 'pack_material/config/material_resource_sub_types/1/material_resource_master_list_items', { matres_master_list_item: { material_resource_product_column_id: 1 }}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_bad_redirect(url: '/pack_material/config/material_resource_sub_types/1/material_resource_master_list_items/new/1')

    # remotely
    PackMaterial::Config::MatresMasterListItem::New.stub(:call, bland_page) do
      post_as_fetch 'pack_material/config/material_resource_sub_types/1/material_resource_master_list_items', { matres_master_list_item: { material_resource_product_column_id: 1 }}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_bad_page
    expect_json_replace_dialog
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
    patch 'pack_material/config/material_resource_sub_types/1/config', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_response
    assert last_response.ok?
    assert last_response.body.include?('notice')
  end

  def test_config_update_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:update_matres_config).returns(bad_response)
    PackMaterial::Config::MatresSubType::Config.stub(:call, bland_page) do
      patch 'pack_material/config/material_resource_sub_types/1/config', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_json_response
    refute last_response.ok?
    assert last_response.body.include?('error')
  end

  def test_prod_code_config
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:update_product_code_configuration).returns(ok_response)
    post 'pack_material/config/material_resource_sub_types/1/update_product_code_configuration', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_ok_redirect
  end

  def test_prod_code_config_remotely
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:update_product_code_configuration).returns(ok_response)
    post_as_fetch 'pack_material/config/material_resource_sub_types/1/update_product_code_configuration', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_ok_json_redirect
  end

  def test_prod_code_config_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:update_product_code_configuration).returns(bad_response)
    PackMaterial::Config::MatresSubType::Config.stub(:call, bland_page) do
      post_as_fetch 'pack_material/config/material_resource_sub_types/1/update_product_code_configuration', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
      end
    expect_bad_redirect(url: '/pack_material/config/material_resource_sub_types/1/config/edit')
    # expect_bad_page

    PackMaterial::Config::MatresSubType::Config.stub(:call, bland_page) do
      post 'pack_material/config/material_resource_sub_types/1/update_product_code_configuration', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_bad_redirect(url: '/pack_material/config/material_resource_sub_types/1/config/edit')
  end

  def test_prod_code_config_remotely_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:update_product_code_configuration).returns(bad_response)
    PackMaterial::Config::MatresSubType::Config.stub(:call, bland_page) do
      post_as_fetch 'pack_material/config/material_resource_sub_types/1/update_product_code_configuration', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_bad_redirect(url: '/pack_material/config/material_resource_sub_types/1/config/edit')
    # expect_json_replace_dialog
  end

  def test_link_product_columns
    authorise_pass!
    ensure_exists!(INTERACTOR)

    PackMaterialApp::ConfigInteractor.any_instance.stubs(:chosen_product_columns).returns(ok_response(instance: OpenStruct.new(code: [1,2,3])))
    post_as_fetch 'pack_material/config/link_product_columns', { selection: { list: '1,2,3' } }, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_response
    assert last_response.ok?
    assert last_response.body.include?('actions')
    assert last_response.body.include?('replace_input_value')
    assert last_response.body.include?('replace_multi_options')
    assert last_response.body.include?('Re-assigned product columns')
  end
end
