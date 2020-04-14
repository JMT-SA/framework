# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/BlockLength

class Framework < Roda
  route 'sales', 'pack_material' do |r|
    # SALES ORDERS
    # --------------------------------------------------------------------------
    r.on 'mr_sales_orders', Integer do |id|
      interactor = PackMaterialApp::MrSalesOrderInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:mr_sales_orders, id) do
        handle_not_found(r)
      end
      r.on 'sales_order_costs' do
        interactor = PackMaterialApp::SalesOrderCostInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})
        r.on 'new' do    # NEW
          check_auth!('dispatch', 'new')
          show_partial_or_page(r) { PackMaterial::Dispatch::SalesOrderCost::New.call(id, remote: fetch?(r)) }
        end
        r.post do        # CREATE
          res = interactor.create_sales_order_cost(id, params[:sales_order_cost])
          if res.success
            row_keys = %i[
              id
              mr_sales_order_id
              mr_cost_type_id
              cost_type_code
              amount
            ]
            add_grid_row(attrs: select_attributes(res.instance, row_keys),
                         notice: res.message)
          else
            re_show_form(r, res, url: "/pack_material/dispatch/mr_sales_orders/#{id}/sales_order_costs/new") do
              PackMaterial::Dispatch::SalesOrderCost::New.call(id,
                                                               form_values: params[:sales_order_cost],
                                                               form_errors: res.errors,
                                                               remote: fetch?(r))
            end
          end
        end
      end
      r.on 'complete_invoice' do
        check_auth!('dispatch', 'edit')
        store_last_referer_url(:sale_complete_invoice)
        res = interactor.complete_invoice(id)
        if res.success
          flash[:notice] = res.message
        else
          flash[:error] = res.message
        end
        redirect_to_stored_referer(r, :sale_complete_invoice)
      end
      r.on 'edit' do   # EDIT
        check_auth!('dispatch', 'edit')
        interactor.assert_permission!(:edit, id)
        show_page { PackMaterial::Dispatch::MrSalesOrder::Edit.call(id, current_user, interactor: interactor) }
      end

      r.on 'ship_goods' do
        check_auth!('dispatch', 'edit')
        res = interactor.ship_mr_sales_order(id)
        if res.success
          flash[:notice] = res.message
        else
          flash[:error] = res.message
        end
        r.redirect("/pack_material/sales/mr_sales_orders/#{id}/edit")
      end

      r.on 'mr_sales_order_items' do
        item_interactor = PackMaterialApp::MrSalesOrderItemInteractor.new(current_user, {}, { route_url: request.path }, {})
        r.on 'new' do    # NEW
          check_auth!('dispatch', 'new')
          show_partial_or_page(r) { PackMaterial::Dispatch::MrSalesOrderItem::New.call(id, remote: fetch?(r)) }
        end
        r.post do        # CREATE
          res = item_interactor.create_mr_sales_order_item(id, params[:mr_sales_order_item])
          if res.success
            redirect_via_json("/pack_material/sales/mr_sales_orders/#{id}/edit")
          else
            re_show_form(r, res, url: "/pack_material/sales/mr_sales_orders/#{id}/mr_sales_order_items/new") do
              PackMaterial::Dispatch::MrSalesOrderItem::New.call(id,
                                                                 form_values: params[:mr_sales_order_item],
                                                                 form_errors: res.errors,
                                                                 remote: fetch?(r))
            end
          end
        end
      end

      r.is do
        r.get do       # SHOW
          check_auth!('dispatch', 'read')
          show_partial { PackMaterial::Dispatch::MrSalesOrder::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_mr_sales_order(id, params[:mr_sales_order])
          if res.success
            flash[:notice] = res.message
            redirect_via_json("/pack_material/sales/mr_sales_orders/#{id}/edit")
          else
            re_show_form(r, res, url: "/pack_material/sales/mr_sales_orders/#{id}/edit") do
              PackMaterial::Dispatch::MrSalesOrder::Edit.call(id,
                                                              current_user,
                                                              form_values: params[:mr_sales_order],
                                                              form_errors: res.errors,
                                                              interactor: interactor)
            end
          end
        end
        r.delete do    # DELETE
          check_auth!('dispatch', 'delete')
          interactor.assert_permission!(:delete, id)
          res = interactor.delete_mr_sales_order(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end

    r.on 'mr_sales_orders' do
      interactor = PackMaterialApp::MrSalesOrderInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'mrpv_location_lookup_result', Integer do |mrpv_id|
        res = interactor.get_mrpv_info(mrpv_id)
        json_actions([OpenStruct.new(type: :replace_input_value,
                                     dom_id: 'mr_sales_order_item_mr_product_variant_id',
                                     value: mrpv_id),
                      OpenStruct.new(type: :replace_input_value,
                                     dom_id: 'mr_sales_order_item_mr_product_variant_code',
                                     value: res[:pv_code]),
                      OpenStruct.new(type: :replace_input_value,
                                     dom_id: 'mr_sales_order_item_mr_product_variant_number',
                                     value: res[:pv_number]),
                      OpenStruct.new(type: :replace_input_value,
                                     dom_id: 'mr_sales_order_item_unit_price',
                                     value: res[:pv_wa_cost].to_f)],
                     'Selected Product Variant')
      end
      r.on 'new' do    # NEW
        check_auth!('dispatch', 'new')
        set_last_grid_url('/list/mr_sales_orders/with_params?key=unshipped', r)
        show_partial_or_page(r) { PackMaterial::Dispatch::MrSalesOrder::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_mr_sales_order(params[:mr_sales_order])
        if res.success
          if fetch?(r)
            redirect_via_json("/pack_material/sales/mr_sales_orders/#{res.instance}/edit")
          else
            flash[:notice] = res.message
            r.redirect "/pack_material/sales/mr_sales_orders/#{res.instance}/edit"
          end
        else
          re_show_form(r, res, url: '/pack_material/sales/mr_sales_orders/new') do
            PackMaterial::Dispatch::MrSalesOrder::New.call(form_values: params[:mr_sales_order],
                                                           form_errors: res.errors,
                                                           remote: fetch?(r))
          end
        end
      end
    end

    # MR SALES ORDER ITEMS
    # --------------------------------------------------------------------------
    r.on 'mr_sales_order_items', Integer do |id|
      interactor = PackMaterialApp::MrSalesOrderItemInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:mr_sales_order_items, id) do
        handle_not_found(r)
      end

      r.on 'inline_save' do
        check_auth!('dispatch', 'edit')
        res = interactor.inline_update(id, params)
        if res.success
          parent_id = interactor.mr_sales_order_item(id)&.mr_sales_order_id
          permission_res = interactor.can_ship(parent_id)
          if permission_res.success
            json_actions([OpenStruct.new(type: :show_element, dom_id: 'mr_sales_orders_ship_button')], res.message)
          else
            json_actions([OpenStruct.new(type: :hide_element, dom_id: 'mr_sales_orders_ship_button')], res.message)
          end
        else
          show_json_error(res.message, status: 200)
        end
      end
      r.is do
        r.patch do     # UPDATE
          res = interactor.update_mr_sales_order_item(id, params[:mr_sales_order_item])
          if res.success
            row_keys = %i[
              id
              mr_sales_order_id
              mr_product_variant_id
              quantity_required
              unit_price
              remarks
              product_variant_code
              product_variant_number
              sku_number
            ]
            update_grid_row(id, changes: select_attributes(res.instance, row_keys), notice: res.message)
          else
            re_show_form(r, res) { PackMaterial::Dispatch::MrSalesOrderItem::Edit.call(id, form_values: params[:mr_sales_order_item], form_errors: res.errors, interactor: interactor) }
          end
        end
        r.delete do    # DELETE
          check_auth!('dispatch', 'delete')
          interactor.assert_permission!(:delete, id)
          res = interactor.delete_mr_sales_order_item(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end

    # SALES ORDER COSTS
    # --------------------------------------------------------------------------
    r.on 'sales_order_costs', Integer do |id|
      interactor = PackMaterialApp::SalesOrderCostInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})

      # Check for notfound:
      r.on !interactor.exists?(:sales_order_costs, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('dispatch', 'edit')
        interactor.assert_permission!(:edit, id)
        show_partial { PackMaterial::Dispatch::SalesOrderCost::Edit.call(id) }
      end
      r.is do
        r.get do       # SHOW
          check_auth!('dispatch', 'read')
          show_partial { PackMaterial::Dispatch::SalesOrderCost::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_sales_order_cost(id, params[:sales_order_cost])
          if res.success
            update_grid_row(id,
                            changes: {
                              mr_sales_order_id: res.instance[:mr_sales_order_id],
                              mr_cost_type_id: res.instance[:mr_cost_type_id],
                              cost_type_code: res.instance[:cost_type_code],
                              amount: res.instance[:amount]
                            },
                            notice: res.message)
          else
            re_show_form(r, res) { PackMaterial::Dispatch::SalesOrderCost::Edit.call(id, form_values: params[:sales_order_cost], form_errors: res.errors) }
          end
        end
        r.delete do    # DELETE
          check_auth!('dispatch', 'delete')
          interactor.assert_permission!(:delete, id)
          res = interactor.delete_sales_order_cost(id)
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
