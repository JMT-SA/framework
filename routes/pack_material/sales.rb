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

      r.on 'complete_invoice' do
        check_auth!('sales', 'edit')
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
        check_auth!('sales', 'edit')
        interactor.assert_permission!(:edit, id)
        show_page { PackMaterial::Sales::MrSalesOrder::Edit.call(id, current_user, interactor: interactor) }
      end

      r.on 'ship_goods' do
        check_auth!('sales', 'edit')
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
          check_auth!('sales', 'new')
          show_partial_or_page(r) { PackMaterial::Sales::MrSalesOrderItem::New.call(id, remote: fetch?(r)) }
        end
        r.post do        # CREATE
          res = item_interactor.create_mr_sales_order_item(id, params[:mr_sales_order_item])
          if res.success
            row_keys = %i[
              id
              mr_sales_order_id
              mr_delivery_item_id
              mr_delivery_item_batch_id
              remarks
              quantity_returned
              status
              product_variant_code
              product_variant_number
              sku_number
            ]
            add_grid_row(attrs: select_attributes(res.instance, row_keys), notice: res.message)
          else
            re_show_form(r, res, url: "/pack_material/sales/mr_sales_orders/#{id}/mr_sales_order_items/new") do
              PackMaterial::Sales::MrSalesOrderItem::New.call(id,
                                                              form_values: params[:mr_sales_order_item],
                                                              form_errors: res.errors,
                                                              remote: fetch?(r))
            end
          end
        end
      end

      r.is do
        r.get do       # SHOW
          check_auth!('sales', 'read')
          show_partial { PackMaterial::Sales::MrSalesOrder::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_mr_sales_order(id, params[:mr_sales_order])
          if res.success
            flash[:notice] = res.message
            r.redirect("/pack_material/sales/mr_sales_orders/#{id}/edit")
          else
            re_show_form(r, res, url: "/pack_material/sales/mr_sales_orders/#{id}/edit") do
              PackMaterial::Sales::MrSalesOrder::Edit.call(id,
                                                           current_user,
                                                           form_values: params[:mr_sales_order],
                                                           form_errors: res.errors,
                                                           interactor: interactor)
            end
          end
        end
        r.delete do    # DELETE
          check_auth!('sales', 'delete')
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
      r.on 'new' do    # NEW
        check_auth!('sales', 'new')
        set_last_grid_url('/list/mr_sales_orders/with_params?key=unshipped', r)
        show_partial_or_page(r) { PackMaterial::Sales::MrSalesOrder::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_mr_sales_order(params[:mr_sales_order])
        if res.success
          if fetch?(r)
            row_keys = %i[
              id
              mr_delivery_id
              delivery_number
              credit_note_number
              issue_transaction_id
              sales_location_id
              created_by
              shipped
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
          re_show_form(r, res, url: '/pack_material/sales/mr_sales_orders/new') do
            PackMaterial::Sales::MrSalesOrder::New.call(form_values: params[:mr_sales_order],
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
        check_auth!('sales', 'edit')
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
              mr_sales_order_id
              mr_delivery_item_id
              mr_delivery_item_batch_id
              remarks
              quantity_returned
              status
              product_variant_code
              product_variant_number
              sku_number
            ]
            update_grid_row(id, changes: select_attributes(res.instance, row_keys), notice: res.message)
          else
            re_show_form(r, res) { PackMaterial::Sales::MrSalesOrderItem::Edit.call(id, form_values: params[:mr_sales_order_item], form_errors: res.errors, interactor: interactor) }
          end
        end
        r.delete do    # DELETE
          check_auth!('sales', 'delete')
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
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/BlockLength
