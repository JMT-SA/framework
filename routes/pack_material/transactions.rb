# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/BlockLength

class Framework < Roda
  route 'transactions', 'pack_material' do |r|
    # ADHOC STOCK TRANSACTIONS
    # --------------------------------------------------------------------------
    r.on 'adhoc_stock_transactions', Integer do |id|
      interactor = PackMaterialApp::MrInventoryTransactionInteractor.new(current_user, {}, { route_url: request.path }, {})
      # Check for notfound:
      r.on !interactor.exists?(:mr_sku_locations, id) do
        handle_not_found(r)
      end

      r.on 'add' do
        check_auth!('transactions', 'new')
        show_partial_or_page(r) { PackMaterial::Transactions::MrInventoryTransaction::New.call(id, type: 'add', remote: fetch?(r)) }
      end
      r.on 'move' do
        check_auth!('transactions', 'new')
        show_partial_or_page(r) { PackMaterial::Transactions::MrInventoryTransaction::New.call(id, type: 'move', remote: fetch?(r)) }
      end
      r.on 'remove' do
        check_auth!('transactions', 'new')
        show_partial_or_page(r) { PackMaterial::Transactions::MrInventoryTransaction::New.call(id, type: 'remove', remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_adhoc_stock_transaction(id, params[:mr_inventory_transaction], params[:type])
        if res.success
          show_json_notice(res.message)
        else
          re_show_form(r, res, url: "/pack_material/transactions/adhoc_stock_transactions/#{id}/#{params[:type]}") do
            PackMaterial::Transactions::MrInventoryTransaction::New.call(id,
                                                                         type: params[:type],
                                                                         form_values: params[:mr_inventory_transaction],
                                                                         form_errors: res.errors,
                                                                         remote: fetch?(r))
          end
        end
      end
      # UNDO link in success message
      # r.is do
      #   r.get do
      #     check_auth!('transactions', 'read')
      #     show_partial { PackMaterial::Transactions::MrInventoryTransaction::Result.call(id) }
      #   end
      # end
    end

    # MR BULK STOCK ADJUSTMENTS
    # --------------------------------------------------------------------------
    r.on 'mr_bulk_stock_adjustments', Integer do |id|
      interactor = PackMaterialApp::MrBulkStockAdjustmentInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:mr_bulk_stock_adjustments, id) do
        handle_not_found(r)
      end

      r.on 'complete' do
        check_auth!('transactions', 'edit')
        store_last_referer_url(:bulk_stock_adjustment_complete)
        res = interactor.complete_bulk_stock_adjustment(id)
        if res.success
          flash[:notice] = res.message
        else
          flash[:error] = res.message
        end
        redirect_to_stored_referer(r, :bulk_stock_adjustment_complete)
      end
      r.on 'reopen' do
        check_auth!('transactions', 'edit')
        store_last_referer_url(:bulk_stock_adjustment_reopen)
        res = interactor.reopen_bulk_stock_adjustment(id)
        if res.success
          flash[:notice] = res.message
        else
          flash[:error] = res.message
        end
        redirect_to_stored_referer(r, :bulk_stock_adjustment_reopen)
      end
      r.on 'approve' do
        check_auth!('transactions', 'edit')
        store_last_referer_url(:bulk_stock_adjustment_approve)
        res = interactor.approve_bulk_stock_adjustment(id)
        if res.success
          flash[:notice] = res.message
        else
          flash[:error] = res.message
        end
        redirect_to_stored_referer(r, :bulk_stock_adjustment_approve)
      end
      r.on 'sign_off' do
        check_auth!('transactions', 'edit')
        store_last_referer_url(:bulk_stock_adjustment_sign_off)
        res = interactor.sign_off_bulk_stock_adjustment(id)
        if res.success
          flash[:notice] = res.message
        else
          flash[:error] = res.message
        end
        redirect_to_stored_referer(r, :bulk_stock_adjustment_sign_off)
      end
      r.on 'decline' do
        check_auth!('transactions', 'edit')
        store_last_referer_url(:bulk_stock_adjustment_decline)
        res = interactor.decline_bulk_stock_adjustment(id)
        if res.success
          flash[:notice] = res.message
        else
          flash[:error] = res.message
        end
        redirect_to_stored_referer(r, :bulk_stock_adjustment_decline)
      end

      r.on 'edit' do   # EDIT
        check_auth!('transactions', 'edit')
        interactor.assert_permission!(:edit, id)
        show_page { PackMaterial::Transactions::MrBulkStockAdjustment::Edit.call(id, current_user) }
      end

      r.on 'edit_header' do   # EDIT HEADER
        check_auth!('transactions', 'edit')
        interactor.assert_permission!(:edit_header, id)
        show_partial { PackMaterial::Transactions::MrBulkStockAdjustment::EditHeader.call(id) }
      end

      r.on 'price_adjustment', Integer do |price_adj_id|
        r.on 'inline_price_adjust' do
          res = interactor.set_price_adjustment_inline(price_adj_id, params)
          if res.success
            show_json_notice(res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end

      r.on 'mr_bulk_stock_adjustment_items' do
        interactor = PackMaterialApp::MrBulkStockAdjustmentItemInteractor.new(current_user, {}, { route_url: request.path }, {})
        r.on 'new' do    # NEW
          check_auth!('transactions', 'new')
          show_partial_or_page(r) { PackMaterial::Transactions::MrBulkStockAdjustmentItem::New.call(id, remote: fetch?(r)) }
        end
        r.post do        # CREATE
          res = interactor.create_mr_bulk_stock_adjustment_item(id, params[:mr_bulk_stock_adjustment_item])
          if res.success
            items = interactor.list_items(id)
            json_actions([
                           OpenStruct.new(type: :change_select_value,
                                          dom_id: 'mr_bulk_stock_adjustment_item_mr_sku_id',
                                          value: ''),
                           OpenStruct.new(type: :change_select_value,
                                          dom_id: 'mr_bulk_stock_adjustment_item_location_id',
                                          value: ''),
                           OpenStruct.new(type: :replace_list_items, dom_id: 'mr_bulk_stock_adjustment_item_list_items', items: items),
                           OpenStruct.new(type: :clear_form_validation, dom_id: 'new_bsa_item')
                         ],
                         'Added new item',
                         keep_dialog_open: true)
          else
            re_show_form(r, res, url: "/pack_material/transactions/mr_bulk_stock_adjustments/#{id}/mr_bulk_stock_adjustment_items/new") do
              PackMaterial::Transactions::MrBulkStockAdjustmentItem::New.call(id,
                                                                              form_values: params[:mr_bulk_stock_adjustment_item],
                                                                              form_errors: res.errors,
                                                                              remote: fetch?(r))
            end
          end
        end
      end

      r.is do
        r.get do       # SHOW
          check_auth!('transactions', 'read')
          show_partial { PackMaterial::Transactions::MrBulkStockAdjustment::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_mr_bulk_stock_adjustment(id, params[:mr_bulk_stock_adjustment])
          if res.success
            row_keys = %i[
              stock_adjustment_number
              active
              is_stock_take
              completed
              approved
              signed_off
            ]
            update_grid_row(id, changes: select_attributes(res.instance, row_keys), notice: res.message)
          else
            re_show_form(r, res) { PackMaterial::Transactions::MrBulkStockAdjustment::EditHeader.call(id, form_values: params[:mr_bulk_stock_adjustment], form_errors: res.errors) }
          end
        end
        r.delete do    # DELETE
          check_auth!('transactions', 'delete')
          interactor.assert_permission!(:delete, id)
          res = interactor.delete_mr_bulk_stock_adjustment(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end

    r.on 'mr_bulk_stock_adjustments' do
      interactor = PackMaterialApp::MrBulkStockAdjustmentInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'sku_location_lookup_result', Integer do |sku_location_id|
        result_hash = interactor.get_sku_location_info_ids(sku_location_id)
        json_actions([OpenStruct.new(type: :change_select_value,
                                     dom_id: 'mr_bulk_stock_adjustment_item_mr_sku_id',
                                     value: result_hash[:sku_id]),
                      OpenStruct.new(type: :change_select_value,
                                     dom_id: 'mr_bulk_stock_adjustment_item_location_id',
                                     value: result_hash[:location_id])],
                     'Selected a SKU Location')
      end
      r.on 'new' do    # NEW
        check_auth!('transactions', 'new')
        show_partial_or_page(r) { PackMaterial::Transactions::MrBulkStockAdjustment::New.call(remote: fetch?(r)) }
      end
      r.on 'link_mr_skus', Integer do |id|
        r.post do
          res = interactor.link_mr_skus(id, multiselect_grid_choices(params))
          if res.success
            update_grid_row(id,
                            changes: { has_skus: res.instance[:has_skus] },
                            notice: res.message)
          else
            show_json_error(res.message)
          end
        end
      end
      r.on 'link_locations', Integer do |id|
        r.post do
          res = interactor.link_locations(id, multiselect_grid_choices(params))
          if res.success
            update_grid_row(id,
                            changes: { has_locations: res.instance[:has_locations] },
                            notice: res.message)
          else
            show_json_error(res.message)
          end
        end
      end
      r.on 'price_adjustment', Integer do |price_adj_id|
        r.on 'inline_price_adjust' do
          res = interactor.set_price_adjustment_inline(price_adj_id, params)
          if res.success
            show_json_notice(res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
      r.post do        # CREATE
        res = interactor.create_mr_bulk_stock_adjustment(params[:mr_bulk_stock_adjustment])
        if res.success
          row_keys = %i[
            id
            stock_adjustment_number
            ref_no
            active
            is_stock_take
            completed
            approved
            signed_off
          ]
          storage_type_id = interactor.pack_material_storage_type_id
          add_grid_row(attrs: select_attributes(res.instance,
                                                row_keys,
                                                storage_type_id: storage_type_id,
                                                has_locations: false,
                                                has_skus: false,
                                                status: 'CREATED'),
                       notice: res.message)
        else
          re_show_form(r, res, url: '/pack_material/transactions/mr_bulk_stock_adjustments/new') do
            PackMaterial::Transactions::MrBulkStockAdjustment::New.call(form_values: params[:mr_bulk_stock_adjustment],
                                                                        form_errors: res.errors,
                                                                        remote: fetch?(r))
          end
        end
      end
    end

    # MR BULK STOCK ADJUSTMENT ITEMS
    # --------------------------------------------------------------------------
    r.on 'mr_bulk_stock_adjustment_items', Integer do |id|
      interactor = PackMaterialApp::MrBulkStockAdjustmentItemInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:mr_bulk_stock_adjustment_items, id) do
        handle_not_found(r)
      end

      r.on 'inline_save' do
        check_auth!('transactions', 'edit')
        res = interactor.inline_update(id, params)
        if res.success
          show_json_notice(res.message)

          parent_id = interactor.mr_bulk_stock_adjustment_item(id)&.mr_bulk_stock_adjustment_id
          permission_res = interactor.can_complete(parent_id)
          if permission_res.success
            json_actions([OpenStruct.new(type: :show_element, dom_id: 'mr_bulk_stock_adjustments_complete_button')],
                         res.message)
          else
            json_actions([OpenStruct.new(type: :hide_element, dom_id: 'mr_bulk_stock_adjustments_complete_button')],
                         res.message)
          end
        else
          show_json_error(res.message, status: 200)
        end
      end

      r.is do
        r.get do       # SHOW
          check_auth!('transactions', 'read')
          show_partial { PackMaterial::Transactions::MrBulkStockAdjustmentItem::Show.call(id) }
        end
        r.delete do    # DELETE
          check_auth!('transactions', 'delete')
          interactor.assert_permission!(:delete, id)
          res = interactor.delete_mr_bulk_stock_adjustment_item(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end
  end
end

# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/BlockLength
