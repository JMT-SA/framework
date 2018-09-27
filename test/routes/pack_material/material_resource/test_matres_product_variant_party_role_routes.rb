# frozen_string_literal: true

require File.join(File.expand_path('./../../../', __dir__), 'test_helper_for_routes')

class TestMatresProductVariantPartyRoleRoutes < RouteTester

  INTERACTOR = PackMaterialApp::MatresProductVariantPartyRoleInteractor

  def test_edit
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigRepo.any_instance.stubs(:find_full_party_role).returns(OpenStruct.new(role_type: 'supplier'))
    PackMaterial::MaterialResource::MatresProductVariantPartyRole::Edit.stub(:call, bland_page) do
      get 'pack_material/material_resource/material_resource_product_variant_party_roles/1/edit', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_edit_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'pack_material/material_resource/material_resource_product_variant_party_roles/1/edit', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_show
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterial::MaterialResource::MatresProductVariantPartyRole::Show.stub(:call, bland_page) do
      get 'pack_material/material_resource/material_resource_product_variant_party_roles/1', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_show_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'pack_material/material_resource/material_resource_product_variant_party_roles/1', {}, 'rack.session' => { user_id: 1 }
    refute last_response.ok?
    assert_match(/permission/i, last_response.body)
  end

  def test_update
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigRepo.any_instance.stubs(:find_full_party_role).returns(OpenStruct.new(role_type: 'supplier'))
    row_vals = Hash.new(1)
    INTERACTOR.any_instance.stubs(:update_matres_product_variant_party_role).returns(ok_response(instance: row_vals))
    patch 'pack_material/material_resource/material_resource_product_variant_party_roles/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_update_grid
  end

  def test_update_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::ConfigRepo.any_instance.stubs(:find_full_party_role).returns(OpenStruct.new(role_type: 'supplier'))
    INTERACTOR.any_instance.stubs(:update_matres_product_variant_party_role).returns(bad_response)
    PackMaterial::MaterialResource::MatresProductVariantPartyRole::Edit.stub(:call, bland_page) do
      patch 'pack_material/material_resource/material_resource_product_variant_party_roles/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_json_replace_dialog(has_error: true)
  end

  def test_delete
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:delete_matres_product_variant_party_role).returns(ok_response)
    delete 'pack_material/material_resource/material_resource_product_variant_party_roles/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_delete_from_grid
  end

  def test_new
    authorise_pass!
    ensure_exists!(INTERACTOR)
    ensure_exists!(PackMaterialApp::MatresProductVariantInteractor)
    PackMaterial::MaterialResource::MatresProductVariantPartyRole::New.stub(:call, bland_page) do
      get  'pack_material/material_resource/material_resource_product_variants/1/material_resource_product_variant_party_roles/new', { type: 'supplier' }, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_new_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    ensure_exists!(PackMaterialApp::MatresProductVariantInteractor)
    get 'pack_material/material_resource/material_resource_product_variants/1/material_resource_product_variant_party_roles/new', { type: 'supplier' }, 'rack.session' => { user_id: 1 }
    refute last_response.ok?
    assert_match(/permission/i, last_response.body)
  end

  def test_create_remotely
    authorise_pass!
    ensure_exists!(INTERACTOR)
    ensure_exists!(PackMaterialApp::MatresProductVariantInteractor)
    INTERACTOR.any_instance.stubs(:create_matres_product_variant_party_role).returns(ok_response)
    post_as_fetch 'pack_material/material_resource/material_resource_product_variants/1/material_resource_product_variant_party_roles', { type: 'supplier' }, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    assert last_response.ok?
    assert last_response.body.include?('/list/material_resource_product_variant_party_roles/with_params?matres_variant_id=1')
    expect_json_response
  end

  def test_create_remotely_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    ensure_exists!(PackMaterialApp::MatresProductVariantInteractor)
    INTERACTOR.any_instance.stubs(:create_matres_product_variant_party_role).returns(bad_response)
    PackMaterial::MaterialResource::MatresProductVariantPartyRole::New.stub(:call, bland_page) do
      post_as_fetch 'pack_material/material_resource/material_resource_product_variants/1/material_resource_product_variant_party_roles', { type: 'supplier' }, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_json_replace_dialog
  end

  private

  def stub_ensure_and_authorize

  end
end
