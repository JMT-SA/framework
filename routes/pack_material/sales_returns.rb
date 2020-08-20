# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/BlockLength

class Framework < Roda
  route 'sales_returns', 'pack_material' do |r|
    # MR SALES RETURNS
    # --------------------------------------------------------------------------
    r.on 'mr_sales_returns', Integer do |id|
      interactor = PackMaterialApp::MrSalesReturnInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})

      # Check for notfound:
      r.on !interactor.exists?(:mr_sales_returns, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('dispatch', 'edit')
        interactor.assert_permission!(:edit, id)
        show_page { PackMaterial::Dispatch::MrSalesReturn::Edit.call(id, current_user, interactor: interactor) }
      end

      r.on 'verify_sales_return' do
        check_auth!('dispatch', 'edit')
        interactor.assert_permission!(:verify_sales_return, id)
        res = interactor.verify_sales_return(id)
        if res.success
          flash[:notice] = res.message
        else
          flash[:error] = res.message
        end
        r.redirect("/pack_material/sales_returns/mr_sales_returns/#{id}/edit")
      end

      r.on 'complete_sales_return' do
        check_auth!('dispatch', 'edit')
        store_last_referer_url(:complete_sales_return)
        interactor.assert_permission!(:complete_sales_return, id)
        res = interactor.complete_sales_return(id)
        if res.success
          flash[:notice] = res.message
        else
          flash[:error] = res.message
        end
        redirect_to_stored_referer(r, :complete_sales_return)
      end

      r.on 'mr_sales_return_items' do
        item_interactor = PackMaterialApp::MrSalesReturnItemInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})
        r.on 'new' do    # NEW
          check_auth!('dispatch', 'new')
          show_partial_or_page(r) { PackMaterial::Dispatch::MrSalesReturnItem::New.call(id, remote: fetch?(r)) }
        end

        r.post do        # CREATE
          res = item_interactor.create_mr_sales_return_item(id, params[:mr_sales_return_item])
          if res.success
            row_keys = %i[
              id
              mr_sales_return_id
              mr_sales_order_item_id
              remarks
              quantity_returned
              quantity_required
              unit_price
              product_variant_code
              status
              created_by
            ]
            add_grid_row(attrs: select_attributes(res.instance, row_keys), notice: res.message)
          else
            re_show_form(r, res, url: "/pack_material/sales_returns/mr_sales_returns/#{id}/mr_sales_return_items/new") do
              PackMaterial::Dispatch::MrSalesReturnItem::New.call(id,
                                                                  form_values: params[:mr_sales_return_item],
                                                                  form_errors: res.errors,
                                                                  remote: fetch?(r))
            end
          end
        end
      end

      r.on 'sales_return_costs' do
        interactor = PackMaterialApp::SalesReturnCostInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})
        r.on 'new' do    # NEW
          check_auth!('dispatch', 'new')
          show_partial_or_page(r) { PackMaterial::Dispatch::SalesReturnCost::New.call(id, remote: fetch?(r)) }
        end
        r.post do        # CREATE
          res = interactor.create_sales_return_cost(id, params[:sales_return_cost])
          if res.success
            row_keys = %i[
              id
              mr_sales_return_id
              mr_cost_type_id
              cost_type_code
              amount
            ]
            add_grid_row(attrs: select_attributes(res.instance, row_keys),
                         notice: res.message)
          else
            re_show_form(r, res, url: "/pack_material/dispatch/mr_sales_returns/#{id}/sales_return_costs/new") do
              PackMaterial::Dispatch::SalesReturnCost::New.call(id,
                                                                form_values: params[:sales_return_cost],
                                                                form_errors: res.errors,
                                                                remote: fetch?(r))
            end
          end
        end
      end

      r.is do
        r.get do       # SHOW
          check_auth!('dispatch', 'read')
          show_partial { PackMaterial::Dispatch::MrSalesReturn::Show.call(id) }
        end

        r.patch do     # UPDATE
          res = interactor.update_mr_sales_return(id, params[:mr_sales_return])
          if res.success
            flash[:notice] = res.message
            r.redirect("/pack_material/sales_returns/mr_sales_returns/#{id}/edit")
          else
            re_show_form(r, res, url: "/pack_material/sales_returns/mr_sales_returns/#{id}/edit") do
              PackMaterial::Dispatch::MrSalesReturn::Edit.call(id, current_user, form_values: params[:mr_sales_return], form_errors: res.errors, interactor: interactor)
            end
          end
        end

        r.delete do    # DELETE
          check_auth!('dispatch', 'delete')
          interactor.assert_permission!(:delete, id)
          res = interactor.delete_mr_sales_return(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end

    r.on 'mr_sales_returns' do
      interactor = PackMaterialApp::MrSalesReturnInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})
      r.on 'new' do    # NEW
        check_auth!('dispatch', 'new')
        set_last_grid_url('/list/mr_sales_returns', r)
        show_partial_or_page(r) { PackMaterial::Dispatch::MrSalesReturn::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_mr_sales_return(params[:mr_sales_return])
        if res.success
          if fetch?(r)
            row_keys = %i[
              id
              mr_sales_order_id
              sales_order_number
              erp_customer_number
              sales_return_number
              issue_transaction_id
              created_by
              remarks
              status
            ]

            add_grid_row(attrs: select_attributes(res.instance, row_keys),
                         notice: res.message)
          else
            flash[:notice] = res.message
            redirect_to_last_grid(r)
          end
        else
          re_show_form(r, res, url: '/pack_material/sales_returns/mr_sales_returns/new') do
            PackMaterial::Dispatch::MrSalesReturn::New.call(form_values: params[:mr_sales_return],
                                                            form_errors: res.errors,
                                                            remote: fetch?(r))
          end
        end
      end
    end

    # MR SALES RETURN ITEMS
    # --------------------------------------------------------------------------
    r.on 'mr_sales_return_items', Integer do |id|
      interactor = PackMaterialApp::MrSalesReturnItemInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})

      # Check for notfound:
      r.on !interactor.exists?(:mr_sales_return_items, id) do
        handle_not_found(r)
      end

      r.on 'inline_save' do
        check_auth!('dispatch', 'edit')
        res = interactor.inline_update(id, params)
        if res.success
          parent_id = interactor.mr_sales_return_item(id)&.mr_sales_return_id
          permission_res = interactor.verify_sales_return(parent_id)
          if permission_res.success
            json_actions([OpenStruct.new(type: :show_element, dom_id: 'mr_sales_returns_verify_button')], res.message)
          else
            json_actions([OpenStruct.new(type: :hide_element, dom_id: 'mr_sales_returns_verify_button')], res.message)
          end
        else
          show_json_error(res.message, status: 200)
        end
      end

      # BARCODE
      # --------------------------------------------------------------------------
      r.on 'print_sku_barcode' do
        interactor = PackMaterialApp::MrSalesReturnItemInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})
        r.get do
          show_partial { PackMaterial::Dispatch::MrSalesReturnItem::PrintBarcode.call(id) }
        end
        r.patch do
          res = interactor.print_sku_barcode(params[:mr_sales_return_item])
          if res.success
            show_json_notice(res.message)
          else
            re_show_form(r, res) do
              PackMaterial::Dispatch::MrSalesReturnItem::PrintBarcode.call(id,
                                                                           form_values: params[:mr_sales_return_item],
                                                                           form_errors: res.errors)
            end
          end
        end
      end

      r.is do
        r.get do       # SHOW
          check_auth!('dispatch', 'read')
          show_partial { PackMaterial::PackMaterial::MrSalesReturnItem::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_mr_sales_return_item(id, params[:mr_sales_return_item])
          if res.success
            row_keys = %i[
              mr_sales_return_id
              mr_sales_order_item_id
              remarks
              quantity_returned
            ]
            update_grid_row(id, changes: select_attributes(res.instance, row_keys), notice: res.message)
          else
            re_show_form(r, res) { PackMaterial::PackMaterial::MrSalesReturnItem::Edit.call(id, form_values: params[:mr_sales_return_item], form_errors: res.errors) }
          end
        end
        r.delete do    # DELETE
          check_auth!('dispatch', 'delete')
          interactor.assert_permission!(:delete, id)
          res = interactor.delete_mr_sales_return_item(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end

    # SALES RETURN COSTS
    # --------------------------------------------------------------------------
    r.on 'sales_return_costs', Integer do |id|
      interactor = PackMaterialApp::SalesReturnCostInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})

      # Check for notfound:
      r.on !interactor.exists?(:sales_return_costs, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('dispatch', 'edit')
        interactor.assert_permission!(:edit, id)
        show_partial { PackMaterial::Dispatch::SalesReturnCost::Edit.call(id) }
      end
      r.is do
        r.get do       # SHOW
          check_auth!('dispatch', 'read')
          show_partial { PackMaterial::Dispatch::SalesReturnCost::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_sales_return_cost(id, params[:sales_return_cost])
          if res.success
            update_grid_row(id,
                            changes: {
                              mr_sales_return_id: res.instance[:mr_sales_return_id],
                              mr_cost_type_id: res.instance[:mr_cost_type_id],
                              cost_type_code: res.instance[:cost_type_code],
                              amount: res.instance[:amount]
                            },
                            notice: res.message)
          else
            re_show_form(r, res) do
              PackMaterial::Dispatch::SalesReturnCost::Edit.call(id,
                                                                 form_values: params[:sales_return_cost],
                                                                 form_errors: res.errors)
            end
          end
        end
        r.delete do    # DELETE
          check_auth!('dispatch', 'delete')
          interactor.assert_permission!(:delete, id)
          res = interactor.delete_sales_return_cost(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end
  end
  def sr_sub_total_changes(sub_totals)
    [
      OpenStruct.new(dom_id: 'sr_totals_subtotal', type: :replace_inner_html, value: sub_totals[:subtotal]),
      OpenStruct.new(dom_id: 'sr_totals_costs', type: :replace_inner_html, value: sub_totals[:costs]),
      OpenStruct.new(dom_id: 'sr_totals_vat', type: :replace_inner_html, value: sub_totals[:vat]),
      OpenStruct.new(dom_id: 'sr_totals_total', type: :replace_inner_html, value: sub_totals[:total])
    ]
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/BlockLength
