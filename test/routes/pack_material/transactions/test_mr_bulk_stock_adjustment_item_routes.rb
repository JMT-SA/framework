# frozen_string_literal: true

require File.join(File.expand_path('./../../../', __dir__), 'test_helper_for_routes')

class TestMrBulkStockAdjustmentItemRoutes < RouteTester

  INTERACTOR = PackMaterialApp::MrBulkStockAdjustmentItemInteractor
  #
  # def test_edit
  #   authorise_pass!
  #   ensure_exists!(INTERACTOR)
  #   PackMaterial::Transactions::MrBulkStockAdjustmentItem::Edit.stub(:call, bland_page) do
  #     get 'pack_material/transactions/mr_bulk_stock_adjustment_items/1/edit', {}, 'rack.session' => { user_id: 1 }
  #   end
  #   expect_bland_page
  # end
  #
  # def test_edit_fail
  #   authorise_fail!
  #   ensure_exists!(INTERACTOR)
  #   get 'pack_material/transactions/mr_bulk_stock_adjustment_items/1/edit', {}, 'rack.session' => { user_id: 1 }
  #   expect_permission_error
  # end
  #
  # def test_show
  #   authorise_pass!
  #   ensure_exists!(INTERACTOR)
  #   PackMaterial::Transactions::MrBulkStockAdjustmentItem::Show.stub(:call, bland_page) do
  #     get 'pack_material/transactions/mr_bulk_stock_adjustment_items/1', {}, 'rack.session' => { user_id: 1 }
  #   end
  #   expect_bland_page
  # end
  #
  # def test_show_fail
  #   authorise_fail!
  #   ensure_exists!(INTERACTOR)
  #   get 'pack_material/transactions/mr_bulk_stock_adjustment_items/1', {}, 'rack.session' => { user_id: 1 }
  #   expect_permission_error
  # end
  #
  # def test_update
  #   authorise_pass!
  #   ensure_exists!(INTERACTOR)
  #   row_vals = Hash.new(1)
  #   INTERACTOR.any_instance.stubs(:update_mr_bulk_stock_adjustment_item).returns(ok_response(instance: row_vals))
  #   patch_as_fetch 'pack_material/transactions/mr_bulk_stock_adjustment_items/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
  #   expect_json_update_grid
  # end
  #
  # def test_update_fail
  #   authorise_pass!
  #   ensure_exists!(INTERACTOR)
  #   INTERACTOR.any_instance.stubs(:update_mr_bulk_stock_adjustment_item).returns(bad_response)
  #   PackMaterial::Transactions::MrBulkStockAdjustmentItem::Edit.stub(:call, bland_page) do
  #     patch_as_fetch 'pack_material/transactions/mr_bulk_stock_adjustment_items/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
  #   end
  #   expect_json_replace_dialog(has_error: true)
  # end
  #
  # def test_delete
  #   authorise_pass!
  #   ensure_exists!(INTERACTOR)
  #   INTERACTOR.any_instance.stubs(:delete_mr_bulk_stock_adjustment_item).returns(ok_response)
  #   delete_as_fetch 'pack_material/transactions/mr_bulk_stock_adjustment_items/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
  #   expect_json_delete_from_grid
  # end
  #
  # def test_delete_fail
  #   authorise_pass!
  #   ensure_exists!(INTERACTOR)
  #   INTERACTOR.any_instance.stubs(:delete_mr_bulk_stock_adjustment_item).returns(bad_response)
  #   delete_as_fetch 'pack_material/transactions/mr_bulk_stock_adjustment_items/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
  #   expect_json_error
  # end
  #
  # def test_new
  #   authorise_pass!
  #   ensure_exists!(INTERACTOR)
  #   PackMaterial::Transactions::MrBulkStockAdjustmentItem::New.stub(:call, bland_page) do
  #     get  'pack_material/transactions/mr_bulk_stock_adjustment_items/new', {}, 'rack.session' => { user_id: 1 }
  #   end
  #   expect_bland_page
  # end
  #
  # def test_new_fail
  #   authorise_fail!
  #   ensure_exists!(INTERACTOR)
  #   get 'pack_material/transactions/mr_bulk_stock_adjustment_items/new', {}, 'rack.session' => { user_id: 1 }
  #   expect_permission_error
  # end
  #
  # def test_create_remotely
  #   authorise_pass!
  #   ensure_exists!(INTERACTOR)
  #   row_vals = Hash.new(1)
  #   INTERACTOR.any_instance.stubs(:create_mr_bulk_stock_adjustment_item).returns(ok_response(instance: row_vals))
  #   post_as_fetch 'pack_material/transactions/mr_bulk_stock_adjustment_items', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
  #   expect_json_add_to_grid(has_notice: true)
  # end
  #
  # def test_create_remotely_fail
  #   authorise_pass!
  #   ensure_exists!(INTERACTOR)
  #   INTERACTOR.any_instance.stubs(:create_mr_bulk_stock_adjustment_item).returns(bad_response)
  #   PackMaterial::Transactions::MrBulkStockAdjustmentItem::New.stub(:call, bland_page) do
  #     post_as_fetch 'pack_material/transactions/mr_bulk_stock_adjustment_items', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
  #   end
  #   expect_json_replace_dialog
  # end
  #
  # # r.on 'inline_save' do
  # #   check_auth!('transactions', 'edit')
  # #   res = interactor.inline_update(id, params)
  # #   if res.success
  # #     show_json_notice(res.message)
  # #
  # #     parent_id = interactor.mr_bulk_stock_adjustment_item(id)&.mr_bulk_stock_adjustment_id
  # #     permission_res = PackMaterialApp::TaskPermissionCheck::MrBulkStockAdjustment.call(:complete, parent_id)
  # #     if permission_res.success
  # #       json_actions([OpenStruct.new(type: :show_element, dom_id: 'mr_bulk_stock_adjustments_complete_button')],
  # #                    res.message)
  # #     else
  # #       json_actions([OpenStruct.new(type: :hide_element, dom_id: 'mr_bulk_stock_adjustments_complete_button')],
  # #                    res.message)
  # #     end
  # #   else
  # #     show_json_error(res.message, status: 200)
  # #   end
  # # end
  # # def test_inline_save
  # #   authorise_pass!
  # #   ensure_exists!(INTERACTOR)
  # #   INTERACTOR.any_instance.stubs(:mr_bulk_stock_adjustment_item).returns(ok_response(instance: OpenStruct.new(mr_bulk_stock_adjustment_id: 1)))
  # #
  # #   PackMaterial::Transactions::MrBulkStockAdjustment::Edit.stub(:call, bland_page) do
  # #     get 'pack_material/transactions/mr_bulk_stock_adjustments/1/edit', {}, 'rack.session' => { user_id: 1 }
  # #   end
  # #   expect_bland_page
  # # end
  # #
  # # def test_inline_save_fail
  # #   authorise_fail!
  # #   ensure_exists!(INTERACTOR)
  # #   get 'pack_material/transactions/mr_bulk_stock_adjustments/1/edit', {}, 'rack.session' => { user_id: 1 }
  # #   expect_permission_error
  # # end
end

#
#
#
# # MR BULK STOCK ADJUSTMENT ITEMS
# # --------------------------------------------------------------------------
# r.on 'mr_bulk_stock_adjustment_items', Integer do |id|
#   interactor = PackMaterialApp::MrBulkStockAdjustmentItemInteractor.new(current_user, {}, { route_url: request.path }, {})
#
#   # Check for notfound:
#   r.on !interactor.exists?(:mr_bulk_stock_adjustment_items, id) do
#     handle_not_found(r)
#   end
#
#   # r.on 'edit' do   # EDIT
#   #   check_auth!('transactions', 'edit')
#   #   interactor.assert_permission!(:edit, id)
#   #   show_partial { PackMaterial::Transactions::MrBulkStockAdjustmentItem::Edit.call(id) }
#   # end
#
#   r.on 'inline_save' do
#     check_auth!('transactions', 'edit')
#     res = interactor.inline_update(id, params)
#     if res.success
#       show_json_notice(res.message)
#
#       parent_id = interactor.mr_bulk_stock_adjustment_item(id)&.mr_bulk_stock_adjustment_id
#       permission_res = PackMaterialApp::TaskPermissionCheck::MrBulkStockAdjustment.call(:complete, parent_id)
#       if permission_res.success
#         json_actions([OpenStruct.new(type: :show_element, dom_id: 'mr_bulk_stock_adjustments_complete_button')],
#                      res.message)
#       else
#         json_actions([OpenStruct.new(type: :hide_element, dom_id: 'mr_bulk_stock_adjustments_complete_button')],
#                      res.message)
#       end
#     else
#       show_json_error(res.message, status: 200)
#     end
#   end
#
#   r.is do
#     r.get do       # SHOW
#       check_auth!('transactions', 'read')
#       show_partial { PackMaterial::Transactions::MrBulkStockAdjustmentItem::Show.call(id) }
#     end
#     # r.patch do     # UPDATE
#     #   res = interactor.update_mr_bulk_stock_adjustment_item(id, params[:mr_bulk_stock_adjustment_item])
#     #   if res.success
#     #     row_keys = %i[
#     #       mr_bulk_stock_adjustment_id
#     #       mr_sku_location_id
#     #       sku_number
#     #       product_variant_number
#     #       product_number
#     #       mr_type_name
#     #       mr_sub_type_name
#     #       product_variant_code
#     #       product_code
#     #       location_long_code
#     #       inventory_uom_code
#     #       scan_to_location_long_code
#     #       system_quantity
#     #       actual_quantity
#     #       stock_take_complete
#     #     ]
#     #     if retrieve_from_local_store(:new_bulk_stock_adjustment_item)
#     #       row_keys << :id
#     #       add_grid_row(attrs: select_attributes(res.instance, row_keys), notice: res.message)
#     #     else
#     #       update_grid_row(id, changes: select_attributes(res.instance, row_keys), notice: res.message)
#     #     end
#     #   else
#     #     re_show_form(r, res) { PackMaterial::Transactions::MrBulkStockAdjustmentItem::Edit.call(id, form_values: params[:mr_bulk_stock_adjustment_item], form_errors: res.errors) }
#     #   end
#     # end
#     r.delete do    # DELETE
#       check_auth!('transactions', 'delete')
#       interactor.assert_permission!(:delete, id)
#       res = interactor.delete_mr_bulk_stock_adjustment_item(id)
#       if res.success
#         delete_grid_row(id, notice: res.message)
#       else
#         show_json_error(res.message, status: 200)
#       end
#     end
#   end
