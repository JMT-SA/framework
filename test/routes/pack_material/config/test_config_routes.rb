# # frozen_string_literal: true
#
# require File.join(File.expand_path('./../../../', __dir__), 'test_helper_for_routes')
#
# class TestConfigRoutes < RouteTester
#   def around
#     PackMaterialApp::ConfigInteractor.any_instance.stubs(:exists?).returns(true)
#     super
#   end
#
#   def test_config_edit
#     PackMaterial::Config::MatresSubType::Config.stub(:call, bland_page) do
#       get 'pack_material/config/material_resource_sub_types/1/config/edit', {}, 'rack.session' => { user_id: 1 }
#     end
#     expect_bland_page
#   end
#
#   def test_config_edit_with_stashed_page
#     Framework.any_instance.stubs(:stashed_page).returns(bland_page(content: 'STASHED_HTML'))
#     PackMaterial::Config::MatresSubType::Config.stub(:call, nil) do
#       get 'pack_material/config/material_resource_sub_types/1/config/edit', {}, 'rack.session' => { user_id: 1 }
#     end
#     expect_bland_page(content: 'STASHED_HTML')
#
#     Framework.any_instance.stubs(:stashed_page).returns(nil)
#     PackMaterial::Config::MatresSubType::Config.stub(:call, bland_page(content: 'NON_STASHED_HTML')) do
#       get 'pack_material/config/material_resource_sub_types/1/config/edit', {}, 'rack.session' => { user_id: 1 }
#     end
#     expect_bland_page(content: 'NON_STASHED_HTML')
#   end
#
#   def test_config_edit_fail
#     authorise_fail!
#     get 'pack_material/config/material_resource_sub_types/1/config/edit', {}, 'rack.session' => { user_id: 1 }
#     expect_permission_error
#   end
#
#   def test_config_update
#     row_vals = Hash.new(1)
#     PackMaterialApp::ConfigInteractor.any_instance.stubs(:update_matres_config).returns(ok_response(instance: row_vals))
#     PackMaterial::Config::MatresSubType::Config.stub(:call, bland_page) do
#       patch 'pack_material/config/material_resource_sub_types/1/config', {}, 'rack.session' => { user_id: 1 }
#     end
#     # Expect good json response
#     assert last_response.ok?
#     assert last_response.body.include?('notice')
#     assert last_response.body.include?(ok_response.message)
#     expect_json_response
#   end
#   def test_config_update_fail
#     PackMaterialApp::ConfigInteractor.any_instance.stubs(:update_matres_config).returns(bad_response)
#     PackMaterial::Config::MatresSubType::Config.stub(:call, bland_page) do
#       patch 'pack_material/config/material_resource_sub_types/1/config', {}, 'rack.session' => { user_id: 1 }
#     end
#     # Expect bad json response
#     assert last_response.ok?
#     assert last_response.body.include?('error')
#     assert last_response.body.include?(bad_response.message)
#     expect_json_response
#   end
#
#   def test_update_product_code_configuration
#     PackMaterialApp::ConfigInteractor.any_instance.stubs(:update_product_code_configuration).returns(ok_response)
#     post 'pack_material/config/material_resource_sub_types/1/update_product_code_configuration', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
#     expect_ok_redirect
#   end
#
#   def test_update_product_code_configuration_fail
#     PackMaterialApp::ConfigInteractor.any_instance.stubs(:update_product_code_configuration).returns(bad_response)
#     PackMaterial::Config::MatresSubType::Config.stub(:call, bland_page) do
#       post 'pack_material/config/material_resource_sub_types/1/update_product_code_configuration', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
#     end
#     expect_bad_redirect(url: '/pack_material/config/material_resource_sub_types/1/config/edit')
#   end
#
#   def test_link_product_columns
#     resp = success_response('got_items', code: [['a', 1], ['a', 2], ['a', 3]], var: [['a', 4]])
#     PackMaterialApp::ConfigInteractor.any_instance.stubs(:chosen_product_columns).returns(resp)
#     post 'pack_material/config/link_product_columns', { selection: { list: '1,2,3,4' } }, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
#     expect_json_response
#     assert last_response.body.include?('notice')
#     assert last_response.body.include?('Re-assigned product columns')
#     assert last_response.body.include?('actions')
#     assert_equal JSON.parse(last_response.body)["actions"].count, 3
#   end
#   # TODO:
#   # Stub CommonHelpers - Explicitly testing only the method I am looking at
#   #   Cascading failing tests are not useful. It just takes longer to find the root of the problem.
# end
