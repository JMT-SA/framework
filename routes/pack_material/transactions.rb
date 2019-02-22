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

      r.on 'edit' do   # EDIT
        check_auth!('transactions', 'edit')
        interactor.assert_permission!(:edit, id)
        show_page { PackMaterial::Transactions::MrBulkStockAdjustment::Edit.call(id) }
      end

      r.on 'edit_header' do   # EDIT
        check_auth!('transactions', 'edit')
        interactor.assert_permission!(:edit_header, id)
        show_partial { PackMaterial::Transactions::MrBulkStockAdjustment::EditHeader.call(id) }
      end

      r.on 'complete' do
        r.get do
          check_auth!('transactions', 'edit')
          interactor.assert_permission!(:complete, id)
          show_partial { PackMaterial::Transactions::MrBulkStockAdjustment::Complete.call(id) }
        end

        r.post do
          res = interactor.complete_a_mr_bulk_stock_adjustment(id, params[:mr_bulk_stock_adjustment])
          if res.success
            flash[:notice] = res.message
            redirect_to_last_grid(r)
          else
            re_show_form(r, res) { PackMaterial::Transactions::MrBulkStockAdjustment::Complete.call(id, params[:mr_bulk_stock_adjustment], res.errors) }
          end
        end
      end

      # r.on 'approve' do
      #   r.get do
      #     check_auth!('transactions', 'approve')
      #     interactor.assert_permission!(:approve, id)
      #     show_partial { PackMaterial::Transactions::MrBulkStockAdjustment::Approve.call(id) }
      #   end

      #   r.post do
      #     res = interactor.approve_or_reject_a_mr_bulk_stock_adjustment(id, params[:mr_bulk_stock_adjustment])
      #     if res.success
      #       flash[:notice] = res.message
      #       redirect_to_last_grid(r)
      #     else
      #       re_show_form(r, res) { PackMaterial::Transactions::MrBulkStockAdjustment::Approve.call(id, params[:mr_bulk_stock_adjustment], res.errors) }
      #     end
      #   end
      # end

      # r.on 'reopen' do
      #   r.get do
      #     check_auth!('transactions', 'edit')
      #     interactor.assert_permission!(:reopen, id)
      #     show_partial { PackMaterial::Transactions::MrBulkStockAdjustment::Reopen.call(id) }
      #   end

      #   r.post do
      #     res = interactor.reopen_a_mr_bulk_stock_adjustment(id, params[:mr_bulk_stock_adjustment])
      #     if res.success
      #       flash[:notice] = res.message
      #       redirect_to_last_grid(r)
      #     else
      #       re_show_form(r, res) { PackMaterial::Transactions::MrBulkStockAdjustment::Reopen.call(id, params[:mr_bulk_stock_adjustment], res.errors) }
      #     end
      #   end
      # end

      r.on 'mr_bulk_stock_adjustment_items' do
        interactor = PackMaterialApp::MrBulkStockAdjustmentItemInteractor.new(current_user, {}, { route_url: request.path }, {})
        r.on 'new' do    # NEW
          check_auth!('transactions', 'new')
          show_partial_or_page(r) { PackMaterial::Transactions::MrBulkStockAdjustmentItem::New.call(id, remote: fetch?(r)) }
        end
        r.post do        # CREATE
          res = interactor.create_mr_bulk_stock_adjustment_item(id, params[:mr_bulk_stock_adjustment_item])
          if res.success
            row_keys = %i[
            id
            mr_bulk_stock_adjustment_id
            mr_sku_location_id
            sku_number
            product_variant_number
            product_number
            mr_type_name
            mr_sub_type_name
            product_variant_code
            product_code
            location_code
            inventory_uom_code
            scan_to_location_code
            system_quantity
            actual_quantity
            stock_take_complete
          ]
            add_grid_row(attrs: select_attributes(res.instance, row_keys),
                         notice: res.message)
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
              sku_numbers
              location_ids
              active
              is_stock_take
              completed
              approved
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
      r.on 'new' do    # NEW
        check_auth!('transactions', 'new')
        show_partial_or_page(r) { PackMaterial::Transactions::MrBulkStockAdjustment::New.call(remote: fetch?(r)) }
      end
      r.on 'link_mr_skus', Integer do |id|
        r.post do
          res = interactor.link_mr_skus(id, multiselect_grid_choices(params))
          if res.success
            flash[:notice] = res.message
          else
            flash[:error] = res.message
          end
          redirect_to_last_grid(r)
        end
      end
      r.on 'link_locations', Integer do |id|
        r.post do
          res = interactor.link_locations(id, multiselect_grid_choices(params))
          if res.success
            flash[:notice] = res.message
          else
            flash[:error] = res.message
          end
          redirect_to_last_grid(r)
        end
      end
      r.post do        # CREATE
        res = interactor.create_mr_bulk_stock_adjustment(params[:mr_bulk_stock_adjustment])
        if res.success
          row_keys = %i[
            id
            stock_adjustment_number
            sku_numbers
            location_ids
            active
            is_stock_take
            completed
            approved
          ]
          add_grid_row(attrs: select_attributes(res.instance, row_keys),
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

      r.on 'edit' do   # EDIT
        check_auth!('transactions', 'edit')
        interactor.assert_permission!(:edit, id)
        show_partial { PackMaterial::Transactions::MrBulkStockAdjustmentItem::Edit.call(id) }
      end

      # r.on 'complete' do
      #   r.get do
      #     check_auth!('transactions', 'edit')
      #     interactor.assert_permission!(:complete, id)
      #     show_partial { PackMaterial::Transactions::MrBulkStockAdjustmentItem::Complete.call(id) }
      #   end

      #   r.post do
      #     res = interactor.complete_a_mr_bulk_stock_adjustment_item(id, params[:mr_bulk_stock_adjustment_item])
      #     if res.success
      #       flash[:notice] = res.message
      #       redirect_to_last_grid(r)
      #     else
      #       re_show_form(r, res) { PackMaterial::Transactions::MrBulkStockAdjustmentItem::Complete.call(id, params[:mr_bulk_stock_adjustment_item], res.errors) }
      #     end
      #   end
      # end

      # r.on 'approve' do
      #   r.get do
      #     check_auth!('transactions', 'approve')
      #     interactor.assert_permission!(:approve, id)
      #     show_partial { PackMaterial::Transactions::MrBulkStockAdjustmentItem::Approve.call(id) }
      #   end

      #   r.post do
      #     res = interactor.approve_or_reject_a_mr_bulk_stock_adjustment_item(id, params[:mr_bulk_stock_adjustment_item])
      #     if res.success
      #       flash[:notice] = res.message
      #       redirect_to_last_grid(r)
      #     else
      #       re_show_form(r, res) { PackMaterial::Transactions::MrBulkStockAdjustmentItem::Approve.call(id, params[:mr_bulk_stock_adjustment_item], res.errors) }
      #     end
      #   end
      # end

      # r.on 'reopen' do
      #   r.get do
      #     check_auth!('transactions', 'edit')
      #     interactor.assert_permission!(:reopen, id)
      #     show_partial { PackMaterial::Transactions::MrBulkStockAdjustmentItem::Reopen.call(id) }
      #   end

      #   r.post do
      #     res = interactor.reopen_a_mr_bulk_stock_adjustment_item(id, params[:mr_bulk_stock_adjustment_item])
      #     if res.success
      #       flash[:notice] = res.message
      #       redirect_to_last_grid(r)
      #     else
      #       re_show_form(r, res) { PackMaterial::Transactions::MrBulkStockAdjustmentItem::Reopen.call(id, params[:mr_bulk_stock_adjustment_item], res.errors) }
      #     end
      #   end
      # end

      r.is do
        r.get do       # SHOW
          check_auth!('transactions', 'read')
          show_partial { PackMaterial::Transactions::MrBulkStockAdjustmentItem::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_mr_bulk_stock_adjustment_item(id, params[:mr_bulk_stock_adjustment_item])
          if res.success
            row_keys = %i[
              mr_bulk_stock_adjustment_id
              mr_sku_location_id
              sku_number
              product_variant_number
              product_number
              mr_type_name
              mr_sub_type_name
              product_variant_code
              product_code
              location_code
              inventory_uom_code
              scan_to_location_code
              system_quantity
              actual_quantity
              stock_take_complete
            ]
            update_grid_row(id, changes: select_attributes(res.instance, row_keys), notice: res.message)
          else
            re_show_form(r, res) { PackMaterial::Transactions::MrBulkStockAdjustmentItem::Edit.call(id, form_values: params[:mr_bulk_stock_adjustment_item], form_errors: res.errors) }
          end
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
