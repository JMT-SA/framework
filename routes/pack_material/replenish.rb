# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/BlockLength

class Framework < Roda
  route 'replenish', 'pack_material' do |r|
    # MR PURCHASE ORDERS
    # --------------------------------------------------------------------------
    r.on 'mr_purchase_orders', Integer do |id|
      interactor = PackMaterialApp::MrPurchaseOrderInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:mr_purchase_orders, id) do
        handle_not_found(r)
      end
      r.on 'mr_purchase_order_items' do
        item_interactor = PackMaterialApp::MrPurchaseOrderItemInteractor.new(current_user, {}, { route_url: request.path }, {})
        r.on 'new' do    # NEW
          check_auth!('replenish', 'new')
          show_partial_or_page(r) { PackMaterial::Replenish::MrPurchaseOrderItem::New.call(id, remote: fetch?(r)) }
        end
        r.post do        # CREATE
          res = item_interactor.create_mr_purchase_order_item(id, params[:mr_purchase_order_item])
          if res.success
            row_keys       = %i[
              id
              mr_purchase_order_id
              mr_product_variant_id
              inventory_uom_id
              quantity_required
              unit_price
              product_variant_code
              inventory_uom_code
            ]
            permission_res = interactor.can_approve_purchase_order(id)
            type           = permission_res.success ? :show_element : :hide_element

            sub_totals = interactor.po_sub_totals(id)
            json_actions(po_sub_total_changes(sub_totals) +
                           [OpenStruct.new(type: :add_grid_row, attrs: select_attributes(res.instance, row_keys)),
                            OpenStruct.new(type: type, dom_id: 'mr_purchase_order_approve_button')],
                         res.message)
          else
            re_show_form(r, res, url: "/pack_material/replenish/mr_purchase_orders/#{id}/mr_purchase_order_items/new") do
              PackMaterial::Replenish::MrPurchaseOrderItem::New.call(id,
                                                                     form_values: params[:mr_purchase_order_item],
                                                                     form_errors: res.errors,
                                                                     remote: fetch?(r))
            end
          end
        end
      end
      r.on 'mr_purchase_order_costs' do
        cost_interactor = PackMaterialApp::MrPurchaseOrderCostInteractor.new(current_user, {}, { route_url: request.path }, {})
        r.on 'new' do    # NEW
          check_auth!('replenish', 'new')
          show_partial_or_page(r) { PackMaterial::Replenish::MrPurchaseOrderCost::New.call(id, remote: fetch?(r)) }
        end
        r.post do        # CREATE
          res = cost_interactor.create_mr_purchase_order_cost(id, params[:mr_purchase_order_cost])
          if res.success
            row_keys = %i[
              id
              mr_cost_type_id
              mr_purchase_order_id
              amount
            ]
            sub_totals = interactor.po_sub_totals(id)
            json_actions(po_sub_total_changes(sub_totals) +
                         [OpenStruct.new(type: :add_grid_row, attrs: select_attributes(res.instance, row_keys, cost_type_code: res.instance[:cost_type]))], res.message)
          else
            re_show_form(r, res, url: "/pack_material/replenish/mr_purchase_orders/#{id}/mr_purchase_order_costs/new") do
              PackMaterial::Replenish::MrPurchaseOrderCost::New.call(id,
                                                                     form_values: params[:mr_purchase_order_cost],
                                                                     form_errors: res.errors,
                                                                     remote: fetch?(r))
            end
          end
        end
      end
      r.on 'approve_purchase_order' do   # EDIT
        check_auth!('replenish', 'edit')
        res = interactor.approve_purchase_order(id)
        if res.success
          flash[:notice] = res.message
        else
          flash[:error] = res.message
        end
        r.redirect("/pack_material/replenish/mr_purchase_orders/#{id}/edit")
      end
      r.on 'edit' do   # EDIT
        check_auth!('replenish', 'edit')
        show_page { PackMaterial::Replenish::MrPurchaseOrder::Edit.call(id, current_user) }
      end
      r.is do
        r.get do       # SHOW
          check_auth!('replenish', 'read')
          # TODO: implement show view
          show_page { PackMaterial::Replenish::MrPurchaseOrder::Edit.call(id, current_user) }
        end
        r.patch do     # UPDATE
          res = interactor.update_mr_purchase_order(id, params[:mr_purchase_order])
          if res.success
            flash[:notice] = res.message
            r.redirect("/pack_material/replenish/mr_purchase_orders/#{id}/edit")
          else
            re_show_form(r, res, url: "/pack_material/replenish/mr_purchase_orders/#{id}/edit") do
              PackMaterial::Replenish::MrPurchaseOrder::Edit.call(id, current_user, form_values: params[:mr_purchase_order], form_errors: res.errors)
            end
          end
        end
        r.delete do    # DELETE
          check_auth!('replenish', 'delete')
          res = interactor.delete_mr_purchase_order(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end
    r.on 'mr_purchase_orders' do
      interactor = PackMaterialApp::MrPurchaseOrderInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'preselect' do
        check_auth!('replenish', 'new')
        show_partial_or_page(r) { PackMaterial::Replenish::MrPurchaseOrder::Preselect.call }
      end
      r.on 'new', Integer do |supplier_id|    # NEW
        check_auth!('replenish', 'new')
        show_partial_or_page(r) { PackMaterial::Replenish::MrPurchaseOrder::New.call(supplier_id) }
      end
      r.on 'new' do
        r.post do
          check_auth!('replenish', 'new')
          supplier_id = params[:mr_purchase_order][:supplier_id].to_i
          re_show_form(r, OpenStruct.new(message: nil), url: "/pack_material/replenish/mr_purchase_orders/new/#{supplier_id}") do
            PackMaterial::Replenish::MrPurchaseOrder::New.call(supplier_id)
          end
        end
      end
      r.post do        # CREATE
        res = interactor.create_mr_purchase_order(params[:mr_purchase_order])
        if res.success
          flash[:notice] = res.message
          r.redirect("/pack_material/replenish/mr_purchase_orders/#{res.instance.id}/edit")
        else
          supplier_id = params[:mr_purchase_order][:supplier_id].to_i
          re_show_form(r, res, url: "/pack_material/replenish/mr_purchase_orders/new/#{supplier_id}") do
            PackMaterial::Replenish::MrPurchaseOrder::New.call(supplier_id,
                                                               form_values: params[:mr_purchase_order],
                                                               form_errors: res.errors)
          end
        end
      end
    end

    # MR PURCHASE ORDER ITEMS
    # --------------------------------------------------------------------------
    r.on 'mr_purchase_order_items', Integer do |id|
      interactor = PackMaterialApp::MrPurchaseOrderItemInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:mr_purchase_order_items, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('replenish', 'edit')
        show_partial { PackMaterial::Replenish::MrPurchaseOrderItem::Edit.call(id) }
      end
      r.is do
        r.get do       # SHOW
          check_auth!('replenish', 'read')
          show_partial { PackMaterial::Replenish::MrPurchaseOrderItem::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_mr_purchase_order_item(id, params[:mr_purchase_order_item])
          if res.success
            row_keys = %i[
              mr_purchase_order_id
              mr_product_variant_id
              inventory_uom_id
              quantity_required
              unit_price
              product_variant_code
              inventory_uom_code
            ]
            sub_totals = interactor.po_sub_totals(id)
            json_actions(po_sub_total_changes(sub_totals) +
                         [OpenStruct.new(ids: id, type: :update_grid_row, changes: select_attributes(res.instance, row_keys))], res.message)
          else
            re_show_form(r, res) { PackMaterial::Replenish::MrPurchaseOrderItem::Edit.call(id, form_values: params[:mr_purchase_order_item], form_errors: res.errors) }
          end
        end
        r.delete do    # DELETE
          check_auth!('replenish', 'delete')
          po_id = interactor.mr_purchase_order_item(id).mr_purchase_order_id
          res = interactor.delete_mr_purchase_order_item(id)

          if res.success
            po_interactor  = PackMaterialApp::MrPurchaseOrderInteractor.new(current_user, {}, { route_url: request.path }, {})
            permission_res = po_interactor.can_approve_purchase_order(po_id)
            type           = permission_res.success ? :show_element : :hide_element

            sub_totals = interactor.po_sub_totals(parent_id: po_id)
            json_actions(po_sub_total_changes(sub_totals) +
                           [OpenStruct.new(id: id, type: :delete_grid_row),
                            OpenStruct.new(type: type, dom_id: 'mr_purchase_order_approve_button')],
                         res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end

    # MR PURCHASE ORDER COSTS
    # --------------------------------------------------------------------------
    r.on 'mr_purchase_order_costs', Integer do |id|
      interactor = PackMaterialApp::MrPurchaseOrderCostInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:mr_purchase_order_costs, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('replenish', 'edit')
        show_partial { PackMaterial::Replenish::MrPurchaseOrderCost::Edit.call(id) }
      end
      r.is do
        r.get do       # SHOW
          check_auth!('replenish', 'read')
          show_partial { PackMaterial::Replenish::MrPurchaseOrderCost::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_mr_purchase_order_cost(id, params[:mr_purchase_order_cost])
          if res.success
            sub_totals = interactor.po_sub_totals(id)
            json_actions(po_sub_total_changes(sub_totals) +
                         [OpenStruct.new(ids: id, type: :update_grid_row, changes:
                                         {
                                           mr_cost_type_id: res.instance[:mr_cost_type_id],
                                           mr_purchase_order_id: res.instance[:mr_purchase_order_id],
                                           cost_type_code: res.instance[:cost_type],
                                           amount: res.instance[:amount]
                                         })], res.message)
          else
            re_show_form(r, res) { PackMaterial::Replenish::MrPurchaseOrderCost::Edit.call(id, form_values: params[:mr_purchase_order_cost], form_errors: res.errors) }
          end
        end
        r.delete do    # DELETE
          check_auth!('replenish', 'delete')
          po_id = interactor.mr_purchase_order_cost(id).mr_purchase_order_id
          res = interactor.delete_mr_purchase_order_cost(id)
          if res.success
            # delete_grid_row(id, notice: res.message)
            sub_totals = interactor.po_sub_totals(po_id)
            json_actions(po_sub_total_changes(sub_totals) +
                         [OpenStruct.new(id: id, type: :delete_grid_row)], res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end

    # MR DELIVERY TERMS
    # --------------------------------------------------------------------------
    r.on 'mr_delivery_terms', Integer do |id|
      interactor = PackMaterialApp::MrDeliveryTermInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:mr_delivery_terms, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('replenish', 'edit')
        show_partial { PackMaterial::Replenish::MrDeliveryTerm::Edit.call(id) }
      end
      r.is do
        r.get do       # SHOW
          check_auth!('replenish', 'read')
          show_partial { PackMaterial::Replenish::MrDeliveryTerm::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_mr_delivery_term(id, params[:mr_delivery_term])
          if res.success
            update_grid_row(id, changes: { delivery_term_code: res.instance[:delivery_term_code], is_consignment_stock: res.instance[:is_consignment_stock] },
                            notice: res.message)
          else
            re_show_form(r, res) { PackMaterial::Replenish::MrDeliveryTerm::Edit.call(id, form_values: params[:mr_delivery_term], form_errors: res.errors) }
          end
        end
        r.delete do    # DELETE
          check_auth!('replenish', 'delete')
          res = interactor.delete_mr_delivery_term(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end
    r.on 'mr_delivery_terms' do
      interactor = PackMaterialApp::MrDeliveryTermInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do    # NEW
        check_auth!('replenish', 'new')
        show_partial_or_page(r) { PackMaterial::Replenish::MrDeliveryTerm::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_mr_delivery_term(params[:mr_delivery_term])
        if res.success
          row_keys = %i[
            id
            delivery_term_code
            is_consignment_stock
          ]
          add_grid_row(attrs: select_attributes(res.instance, row_keys),
                       notice: res.message)
        else
          re_show_form(r, res, url: '/pack_material/replenish/mr_delivery_terms/new') do
            PackMaterial::Replenish::MrDeliveryTerm::New.call(form_values: params[:mr_delivery_term],
                                                              form_errors: res.errors,
                                                              remote: fetch?(r))
          end
        end
      end
    end

    # MR DELIVERIES
    # --------------------------------------------------------------------------
    r.on 'mr_deliveries', Integer do |id|
      interactor = PackMaterialApp::MrDeliveryInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:mr_deliveries, id) do
        handle_not_found(r)
      end

      r.on 'mr_purchase_invoice_costs' do
        cost_interactor = PackMaterialApp::MrPurchaseInvoiceCostInteractor.new(current_user, {}, { route_url: request.path }, {})
        r.on 'new' do    # NEW
          check_auth!('replenish', 'new')
          show_partial_or_page(r) { PackMaterial::Replenish::MrPurchaseInvoiceCost::New.call(id, remote: fetch?(r)) }
        end
        r.post do        # CREATE
          res = cost_interactor.create_mr_purchase_invoice_cost(id, params[:mr_purchase_invoice_cost])
          if res.success
            row_keys = %i[
              id
              mr_delivery_id
              amount
            ]
            sub_totals = interactor.del_sub_totals(id)
            json_actions(del_sub_total_changes(sub_totals) +
                         [OpenStruct.new(type: :add_grid_row, attrs: select_attributes(res.instance, row_keys, cost_type_code: res.instance[:cost_type]))], res.message)
          else
            re_show_form(r, res, url: '/pack_material/replenish/mr_purchase_invoice_costs/new') do
              PackMaterial::Replenish::MrPurchaseInvoiceCost::New.call(id,
                                                                       form_values: params[:mr_purchase_invoice_cost],
                                                                       form_errors: res.errors,
                                                                       remote: fetch?(r))
            end
          end
        end
      end
      r.on 'mr_delivery_items' do
        item_interactor = PackMaterialApp::MrDeliveryItemInteractor.new(current_user, {}, { route_url: request.path }, {})
        r.on 'preselect' do
          check_auth!('replenish', 'new')
          store_last_referer_url(:delivery_items)
          show_partial_or_page(r) { PackMaterial::Replenish::MrDeliveryItem::Preselect.call(id, purchase_order_id: flash[:purchase_order_id]) }
        end
        r.on 'quantity_received_changed' do
          qty_received = params[:changed_value].empty? ? nil : params[:changed_value]
          quantities   = qty_received ? item_interactor.over_under_supply(qty_received, params[:mr_delivery_item_mr_purchase_order_item_id]) : {}
          json_actions([OpenStruct.new(dom_id: 'mr_delivery_item_quantity_over_supplied', type: :replace_inner_html, value: quantities[:quantity_over_supplied].to_f),
                        OpenStruct.new(dom_id: 'mr_delivery_item_quantity_under_supplied', type: :replace_inner_html, value: quantities[:quantity_under_supplied].to_f)])
        end
        r.on 'purchase_order_changed' do
          po_id = params[:changed_value].empty? ? nil : params[:changed_value]
          options_array = po_id ? item_interactor.available_purchase_order_items(params[:changed_value], id) : []
          json_replace_select_options('mr_delivery_item_mr_purchase_order_item_id', options_array, message: nil, keep_dialog_open: true)
        end
        r.on 'done' do
          redirect_to_stored_referer(r, :delivery_items)
        end
        r.on 'new', Integer do |item_id|
          check_auth!('replenish', 'new')
          show_partial_or_page(r) { PackMaterial::Replenish::MrDeliveryItem::New.call(id, item_id) }
        end
        r.on 'new' do
          r.post do
            check_auth!('replenish', 'new')
            item_id = params[:mr_delivery_item][:mr_purchase_order_item_id]
            if item_id && !item_id.empty?
              re_show_form(r, OpenStruct.new(message: nil), url: "/pack_material/replenish/mr_deliveries/#{id}/mr_delivery_items/new/#{item_id}") do
                PackMaterial::Replenish::MrDeliveryItem::New.call(id, Integer(item_id))
              end
            else
              show_json_error('No Purchase Order Item was selected', status: 200)
            end
          end
        end
        r.post do        # CREATE
          res = item_interactor.create_mr_delivery_item(id, params[:mr_delivery_item])
          if res.success
            flash[:purchase_order_id] = item_interactor.purchase_order_id_for_delivery_item(res.instance.id)
            r.redirect("/pack_material/replenish/mr_deliveries/#{id}/mr_delivery_items/preselect")
          else
            re_show_form(r, res, url: "/pack_material/replenish/mr_deliveries/#{id}/mr_delivery_items/new") do
              PackMaterial::Replenish::MrDeliveryItem::New.call(id,
                                                                params[:mr_delivery_item][:mr_purchase_order_item_id],
                                                                form_values: params[:mr_delivery_item],
                                                                form_errors: res.errors,
                                                                remote: fetch?(r))
            end
          end
        end
      end
      r.on 'verify' do   # EDIT
        check_auth!('replenish', 'edit')
        store_last_referer_url(:delivery_verify)
        res = interactor.verify_mr_delivery(id)
        if res.success
          flash[:notice] = res.message
        else
          flash[:error] = res.message
        end
        redirect_to_stored_referer(r, :delivery_verify)
      end
      r.on 'complete_invoice' do   # EDIT
        check_auth!('replenish', 'edit')
        store_last_referer_url(:delivery_complete_invoice)
        res = interactor.complete_invoice(id)
        if res.success
          flash[:notice] = res.message
        else
          flash[:error] = res.message
        end
        redirect_to_stored_referer(r, :delivery_complete_invoice)
      end
      r.on 'edit' do   # EDIT
        check_auth!('replenish', 'edit')
        show_page { PackMaterial::Replenish::MrDelivery::Edit.call(id) }
      end

      r.on 'invoice' do
        r.is do
          r.get do
            check_auth!('replenish', 'edit')
            show_partial_or_page(r) { PackMaterial::Replenish::MrDelivery::Invoice.call(id, remote: fetch?(r)) }
          end
          r.patch do
            res = interactor.update_mr_delivery_purchase_invoice(id, params[:mr_delivery])
            if res.success
              flash[:notice] = res.message
              if fetch?(r)
                redirect_via_json("/pack_material/replenish/mr_deliveries/#{id}/edit")
              else
                r.redirect("/pack_material/replenish/mr_deliveries/#{id}/edit")
              end
            else
              re_show_form(r, res, url: "/pack_material/replenish/mr_deliveries/#{id}/invoice") do
                PackMaterial::Replenish::MrDelivery::Invoice.call(id, form_values: params[:mr_delivery], form_errors: res.errors)
              end
            end
          end
        end
      end

      r.is do
        r.get do       # SHOW
          check_auth!('replenish', 'read')
          show_page { PackMaterial::Replenish::MrDelivery::Edit.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_mr_delivery(id, params[:mr_delivery])
          if res.success
            flash[:notice] = res.message
            r.redirect("/pack_material/replenish/mr_deliveries/#{id}/edit")
          else
            re_show_form(r, res, url: "/pack_material/replenish/mr_deliveries/#{id}/edit") do
              PackMaterial::Replenish::MrDelivery::Edit.call(id, form_values: params[:mr_delivery], form_errors: res.errors)
            end
          end
        end
        r.delete do    # DELETE
          check_auth!('replenish', 'delete')
          res = interactor.delete_mr_delivery(id)
          if res.success
            redirect_to_last_grid(r)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end
    r.on 'mr_deliveries' do
      interactor = PackMaterialApp::MrDeliveryInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do    # NEW
        check_auth!('replenish', 'new')
        show_partial_or_page(r) { PackMaterial::Replenish::MrDelivery::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_mr_delivery(params[:mr_delivery])
        if res.success
          flash[:notice] = res.message
          if fetch?(r)
            redirect_via_json("/pack_material/replenish/mr_deliveries/#{res.instance.id}/edit")
          else
            r.redirect("/pack_material/replenish/mr_deliveries/#{res.instance.id}/edit")
          end
        else
          re_show_form(r, res, url: '/pack_material/replenish/mr_deliveries/new') do
            PackMaterial::Replenish::MrDelivery::New.call(form_values: params[:mr_delivery],
                                                          form_errors: res.errors,
                                                          remote: fetch?(r))
          end
        end
      end
    end

    # MR DELIVERY ITEMS
    # --------------------------------------------------------------------------
    r.on 'mr_delivery_items', Integer do |id|
      interactor = PackMaterialApp::MrDeliveryItemInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:mr_delivery_items, id) do
        handle_not_found(r)
      end

      r.on 'inline_save' do
        check_auth!('replenish', 'edit')
        del_interactor = PackMaterialApp::MrDeliveryInteractor.new(current_user, {}, { route_url: request.path }, {})
        res = interactor.inline_update(id, params)
        if res.success
          show_json_notice(res.message)

          parent_id = interactor.mr_delivery_item(id)&.mr_delivery_id
          permission_res = interactor.can_complete_invoice(parent_id)
          sub_totals = del_interactor.del_sub_totals(parent_id)
          if permission_res.success
            json_actions(del_sub_total_changes(sub_totals) +
                         [OpenStruct.new(type: :show_element, dom_id: 'mr_delivery_complete_button')],
                         res.message)
          else
            json_actions(del_sub_total_changes(sub_totals) +
                         [OpenStruct.new(type: :hide_element, dom_id: 'mr_delivery_complete_button')],
                         res.message)
          end
        else
          show_json_error(res.message, status: 200)
        end
      end
      r.on 'mr_delivery_item_batches' do
        interactor = PackMaterialApp::MrDeliveryItemBatchInteractor.new(current_user, {}, { route_url: request.path }, {})
        r.on 'new' do    # NEW
          check_auth!('replenish', 'new')
          store_last_referer_url(:delivery_item_batch)
          show_partial_or_page(r) { PackMaterial::Replenish::MrDeliveryItemBatch::New.call(id, remote: fetch?(r)) }
        end
        r.post do        # CREATE
          res = interactor.create_mr_delivery_item_batch(id, params[:mr_delivery_item_batch])
          if res.success
            flash[:notice] = res.message
            redirect_via_json_to_stored_referer(:delivery_item_batch)
          else
            re_show_form(r, res, url: "/pack_material/replenish/mr_delivery_items/#{id}/mr_delivery_item_batches/new") do
              PackMaterial::Replenish::MrDeliveryItemBatch::New.call(id,
                                                                     form_values: params[:mr_delivery_item_batch],
                                                                     form_errors: res.errors,
                                                                     remote: fetch?(r))
            end
          end
        end
      end
      r.on 'edit' do   # EDIT
        check_auth!('replenish', 'edit')
        store_last_referer_url(:delivery_items)
        show_partial { PackMaterial::Replenish::MrDeliveryItem::Edit.call(id) }
      end

      r.is do
        r.get do       # SHOW
          check_auth!('replenish', 'read')
          show_partial { PackMaterial::Replenish::MrDeliveryItem::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_mr_delivery_item(id, params[:mr_delivery_item])
          if res.success
            redirect_via_json_to_stored_referer(:delivery_items)
          else
            re_show_form(r, res) {
              PackMaterial::Replenish::MrDeliveryItem::Edit.call(id,
                                                                 form_values: params[:mr_delivery_item],
                                                                 form_errors: res.errors)
            }
          end
        end
        r.delete do    # DELETE
          check_auth!('replenish', 'delete')
          store_last_referer_url(:delivery_item_delete)
          res = interactor.delete_mr_delivery_item(id)
          if res.success
            redirect_via_json_to_stored_referer(:delivery_item_delete)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end

    # MR DELIVERY ITEM BATCHES
    # --------------------------------------------------------------------------
    r.on 'mr_delivery_item_batches', Integer do |id|
      interactor = PackMaterialApp::MrDeliveryItemBatchInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:mr_delivery_item_batches, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('replenish', 'edit')
        store_last_referer_url(:delivery_item_batch)
        show_partial { PackMaterial::Replenish::MrDeliveryItemBatch::Edit.call(id) }
      end

      r.is do
        r.get do       # SHOW
          check_auth!('replenish', 'read')
          show_partial { PackMaterial::Replenish::MrDeliveryItemBatch::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_mr_delivery_item_batch(id, params[:mr_delivery_item_batch])
          if res.success
            flash[:notice] = res.message
            redirect_via_json_to_stored_referer(:delivery_item_batch)
          else
            re_show_form(r, res) { PackMaterial::Replenish::MrDeliveryItemBatch::Edit.call(id, form_values: params[:mr_delivery_item_batch], form_errors: res.errors) }
          end
        end
        r.delete do    # DELETE
          check_auth!('replenish', 'delete')
          store_last_referer_url(:delivery_item_batch_delete)
          res = interactor.delete_mr_delivery_item_batch(id)
          if res.success
            flash[:notice] = res.message
            redirect_via_json_to_stored_referer(:delivery_item_batch_delete)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end

    # BARCODE
    # --------------------------------------------------------------------------
    r.on 'print_sku_barcode' do
      interactor = PackMaterialApp::MrDeliveryItemBatchInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.get do
        attrs = interactor.resolve_print_sku_barcode_params(params)
        show_partial { PackMaterial::Replenish::MrDeliveryItemBatch::PrintBarcode.call(attrs[:id], type: attrs[:type]) }
      end
      r.patch do
        res = interactor.print_sku_barcode(params)
        if res.success
          show_json_notice(res.message)
        else
          attrs = interactor.resolve_print_sku_barcode_params(params)
          re_show_form(r, res) { PackMaterial::Replenish::MrDeliveryItemBatch::PrintBarcode.call(attrs[:id], form_values: params[:mr_delivery_item_batch], form_errors: res.errors, type: attrs[:type]) }
        end
      end
    end

    # MR COST TYPES
    # --------------------------------------------------------------------------
    r.on 'mr_cost_types', Integer do |id|
      interactor = PackMaterialApp::MrCostTypeInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:mr_cost_types, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('replenish', 'edit')
        show_partial { PackMaterial::Replenish::MrCostType::Edit.call(id) }
      end

      r.is do
        r.get do       # SHOW
          check_auth!('replenish', 'read')
          show_partial { PackMaterial::Replenish::MrCostType::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_mr_cost_type(id, params[:mr_cost_type])
          if res.success
            update_grid_row(id, changes: { cost_type_code: res.instance[:cost_type_code] },
                            notice: res.message)
          else
            re_show_form(r, res) { PackMaterial::Replenish::MrCostType::Edit.call(id, form_values: params[:mr_cost_type], form_errors: res.errors) }
          end
        end
        r.delete do    # DELETE
          check_auth!('replenish', 'delete')
          res = interactor.delete_mr_cost_type(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end
    r.on 'mr_cost_types' do
      interactor = PackMaterialApp::MrCostTypeInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do    # NEW
        check_auth!('replenish', 'new')
        show_partial_or_page(r) { PackMaterial::Replenish::MrCostType::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_mr_cost_type(params[:mr_cost_type])
        if res.success
          row_keys = %i[
            id
            cost_type_code
          ]
          add_grid_row(attrs: select_attributes(res.instance, row_keys),
                       notice: res.message)
        else
          re_show_form(r, res, url: '/pack_material/replenish/mr_cost_types/new') do
            PackMaterial::Replenish::MrCostType::New.call(form_values: params[:mr_cost_type],
                                                          form_errors: res.errors,
                                                          remote: fetch?(r))
          end
        end
      end
    end

    # MR PURCHASE INVOICE COSTS
    # --------------------------------------------------------------------------
    r.on 'mr_purchase_invoice_costs', Integer do |id|
      interactor = PackMaterialApp::MrPurchaseInvoiceCostInteractor.new(current_user, {}, { route_url: request.path }, {})
      del_interactor = PackMaterialApp::MrDeliveryInteractor.new(current_user, {}, { route_url: request.path }, {})
      # Check for notfound:
      r.on !interactor.exists?(:mr_purchase_invoice_costs, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('replenish', 'edit')
        show_partial { PackMaterial::Replenish::MrPurchaseInvoiceCost::Edit.call(id) }
      end

      r.is do
        r.get do       # SHOW
          check_auth!('replenish', 'read')
          show_partial { PackMaterial::Replenish::MrPurchaseInvoiceCost::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_mr_purchase_invoice_cost(id, params[:mr_purchase_invoice_cost])
          if res.success
            sub_totals = del_interactor.del_sub_totals(res.instance[:mr_delivery_id])
            json_actions(del_sub_total_changes(sub_totals) +
                           [OpenStruct.new(ids: id,
                                           type: :update_grid_row,
                                           changes: { mr_cost_type_id: res.instance[:mr_cost_type_id],
                                                      mr_delivery_id: res.instance[:mr_delivery_id],
                                                      amount: res.instance[:amount],
                                                      cost_type_code: res.instance[:cost_type] })],
                         res.message)
          else
            re_show_form(r, res) { PackMaterial::Replenish::MrPurchaseInvoiceCost::Edit.call(id, form_values: params[:mr_purchase_invoice_cost], form_errors: res.errors) }
          end
        end
        r.delete do    # DELETE
          check_auth!('replenish', 'delete')
          delivery_id = interactor.mr_purchase_invoice_cost(id)&.mr_delivery_id
          res = interactor.delete_mr_purchase_invoice_cost(id)
          if res.success
            sub_totals = del_interactor.del_sub_totals(delivery_id)
            json_actions(del_sub_total_changes(sub_totals) +
                           [OpenStruct.new(id: id, type: :delete_grid_row)], res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end
  end

  def po_sub_total_changes(sub_totals)
    [
      OpenStruct.new(dom_id: 'po_totals_subtotal', type: :replace_inner_html, value: sub_totals[:subtotal]),
      OpenStruct.new(dom_id: 'po_totals_costs', type: :replace_inner_html, value: sub_totals[:costs]),
      OpenStruct.new(dom_id: 'po_totals_vat', type: :replace_inner_html, value: sub_totals[:vat]),
      OpenStruct.new(dom_id: 'po_totals_total', type: :replace_inner_html, value: sub_totals[:total]),
    ]
  end

  def del_sub_total_changes(sub_totals)
    [
      OpenStruct.new(dom_id: 'del_totals_subtotal', type: :replace_inner_html, value: sub_totals[:subtotal]),
      OpenStruct.new(dom_id: 'del_totals_costs', type: :replace_inner_html, value: sub_totals[:costs]),
      OpenStruct.new(dom_id: 'del_totals_vat', type: :replace_inner_html, value: sub_totals[:vat]),
      OpenStruct.new(dom_id: 'del_totals_total', type: :replace_inner_html, value: sub_totals[:total]),
    ]
  end
end

# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/BlockLength
