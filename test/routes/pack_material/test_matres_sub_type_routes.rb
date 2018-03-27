# frozen_string_literal: true

require File.join(File.expand_path('./../../../', __FILE__), 'test_helper_for_routes')

class TestMatresSubTypeRoutes < RouteTester
  def around
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:exists?).returns(true)
    super
  end

  def test_edit
    PackMaterial::Config::MatresSubType::Edit.stub(:call, bland_page) do
      get 'pack_material/config/material_resource_sub_types/1/edit', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_edit_fail
    authorise_fail!
    get 'pack_material/config/material_resource_sub_types/1/edit', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_show
    PackMaterial::Config::MatresSubType::Show.stub(:call, bland_page) do
      get 'pack_material/config/material_resource_sub_types/1', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_show_fail
    authorise_fail!
    get 'pack_material/config/material_resource_sub_types/1', {}, 'rack.session' => { user_id: 1 }
    refute last_response.ok?
    assert_match(/permission/i, last_response.body)
  end

  def test_update
    row_vals = Hash.new(1)
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:update_matres_sub_type).returns(ok_response(instance: row_vals))
    patch 'pack_material/config/material_resource_sub_types/1', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    expect_json_update_grid
  end

  def test_update_fail
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:update_matres_sub_type).returns(bad_response)
    PackMaterial::Config::MatresSubType::Edit.stub(:call, bland_page) do
      patch 'pack_material/config/material_resource_sub_types/1', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    end
    expect_json_replace_dialog(has_error: true)
  end

  def test_delete
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:delete_matres_sub_type).returns(ok_response)
    delete 'pack_material/config/material_resource_sub_types/1', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    expect_json_delete_from_grid
  end
  #
  # def test_delete_fail
  #   PackMaterialApp::ConfigInteractor.any_instance.stubs(:delete_matres_sub_type).returns(bad_response)
  #   delete 'pack_material/config/material_resource_sub_types/1', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
  #   expect_bad_redirect
  # end

  def test_new
    PackMaterial::Config::MatresSubType::New.stub(:call, bland_page) do
      get  'pack_material/config/material_resource_sub_types/new', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_new_fail
    authorise_fail!
    get 'pack_material/config/material_resource_sub_types/new', {}, 'rack.session' => { user_id: 1 }
    refute last_response.ok?
    assert_match(/permission/i, last_response.body)
  end

  def test_create
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:create_matres_sub_type).returns(ok_response)
    post 'pack_material/config/material_resource_sub_types', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    expect_ok_redirect
  end

  def test_create_remotely
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:create_matres_sub_type).returns(ok_response)
    post_as_fetch 'pack_material/config/material_resource_sub_types', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    expect_ok_json_redirect
  end

  def test_create_fail
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:create_matres_sub_type).returns(bad_response)
    PackMaterial::Config::MatresSubType::New.stub(:call, bland_page) do
      post 'pack_material/config/material_resource_sub_types', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    end
    expect_bad_redirect(url: '/pack_material/config/material_resource_sub_types/new')
  end

  def test_create_remotely_fail
    PackMaterialApp::ConfigInteractor.any_instance.stubs(:create_matres_sub_type).returns(bad_response)
    PackMaterial::Config::MatresSubType::New.stub(:call, bland_page) do
      post_as_fetch 'pack_material/config/material_resource_sub_types', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    end
    expect_json_replace_dialog
  end
end
