# frozen_string_literal: true

require File.join(File.expand_path('./../../../', __dir__), 'test_helper_for_routes')

class TestMatresProductVariantRoutes < RouteTester

  INTERACTOR = PackMaterialApp::MatresProductVariantInteractor

  def test_edit
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterial::MaterialResource::MatresProductVariant::Edit.stub(:call, bland_page) do
      get 'pack_material/material_resource/material_resource_product_variants/1/edit', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_edit_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'pack_material/material_resource/material_resource_product_variants/1/edit', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_update
    authorise_pass!
    ensure_exists!(INTERACTOR)
    row_vals = Hash.new(1)
    INTERACTOR.any_instance.stubs(:update_matres_product_variant).returns(ok_response(instance: row_vals))
    patch_as_fetch 'pack_material/material_resource/material_resource_product_variants/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_update_grid
  end

  def test_update_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:update_matres_product_variant).returns(bad_response)
    PackMaterial::MaterialResource::MatresProductVariant::Edit.stub(:call, bland_page) do
      patch_as_fetch 'pack_material/material_resource/material_resource_product_variants/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_json_replace_dialog(has_error: true)
  end

  # def test_delete
  #   authorise_pass!
  #   ensure_exists!(INTERACTOR)
  #   INTERACTOR.any_instance.stubs(:delete_matres_product_variant).returns(ok_response)
  #   delete 'pack_material/material_resource/material_resource_product_variants/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
  #   expect_json_delete_from_grid
  # end
  #
  # def test_delete_fail
  #   authorise_pass!
  #   ensure_exists!(INTERACTOR)
  #   INTERACTOR.any_instance.stubs(:delete_matres_product_variant).returns(bad_response)
  #   delete 'pack_material/material_resource/material_resource_product_variants/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
  #   expect_bad_redirect
  # end
  #
  # def test_new
  #   authorise_pass!
  #   ensure_exists!(INTERACTOR)
  #   PackMaterial::MaterialResource::MatresProductVariant::New.stub(:call, bland_page) do
  #     get  'pack_material/material_resource/material_resource_product_variants/new', {}, 'rack.session' => { user_id: 1 }
  #   end
  #   expect_bland_page
  # end
  #
  # def test_new_fail
  #   authorise_fail!
  #   ensure_exists!(INTERACTOR)
  #   get 'pack_material/material_resource/material_resource_product_variants/new', {}, 'rack.session' => { user_id: 1 }
  #   refute last_response.ok?
  #   assert_match(/permission/i, last_response.body)
  # end
  #
  # def test_create
  #   authorise_pass!
  #   ensure_exists!(INTERACTOR)
  #   INTERACTOR.any_instance.stubs(:create_matres_product_variant).returns(ok_response)
  #   post 'pack_material/material_resource/material_resource_product_variants', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
  #   expect_ok_redirect
  # end
  #
  # def test_create_remotely
  #   authorise_pass!
  #   ensure_exists!(INTERACTOR)
  #   INTERACTOR.any_instance.stubs(:create_matres_product_variant).returns(ok_response)
  #   post_as_fetch 'pack_material/material_resource/material_resource_product_variants', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
  #   expect_ok_json_redirect
  # end
  #
  # def test_create_fail
  #   authorise_pass!
  #   ensure_exists!(INTERACTOR)
  #   INTERACTOR.any_instance.stubs(:create_matres_product_variant).returns(bad_response)
  #   PackMaterial::MaterialResource::MatresProductVariant::New.stub(:call, bland_page) do
  #     post_as_fetch 'pack_material/material_resource/material_resource_product_variants', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
  #   end
  #   expect_bad_page
  #
  #   PackMaterial::MaterialResource::MatresProductVariant::New.stub(:call, bland_page) do
  #     post 'pack_material/material_resource/material_resource_product_variants', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
  #   end
  #   expect_bad_redirect(url: '/pack_material/material_resource/material_resource_product_variants/new')
  # end
  #
  # def test_create_remotely_fail
  #   authorise_pass!
  #   ensure_exists!(INTERACTOR)
  #   INTERACTOR.any_instance.stubs(:create_matres_product_variant).returns(bad_response)
  #   PackMaterial::MaterialResource::MatresProductVariant::New.stub(:call, bland_page) do
  #     post_as_fetch 'pack_material/material_resource/material_resource_product_variants', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
  #   end
  #   expect_json_replace_dialog
  # end
end
