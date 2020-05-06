# frozen_string_literal: true

module PackMaterialApp
  class DispatchRepo < BaseRepo # rubocop:disable Metrics/ClassLength
    build_for_select :mr_goods_returned_notes,
                     label: :created_by,
                     value: :id,
                     no_active_check: true,
                     order_by: :created_by

    crud_calls_for :mr_goods_returned_notes, name: :mr_goods_returned_note, wrapper: MrGoodsReturnedNote

    build_for_select :mr_goods_returned_note_items,
                     label: :remarks,
                     value: :id,
                     no_active_check: true,
                     order_by: :remarks

    crud_calls_for :mr_goods_returned_note_items, name: :mr_goods_returned_note_item, wrapper: MrGoodsReturnedNoteItem

    build_for_select :mr_sales_orders,
                     label: :erp_customer_number,
                     value: :id,
                     no_active_check: true,
                     order_by: :erp_customer_number

    crud_calls_for :mr_sales_orders, name: :mr_sales_order, wrapper: MrSalesOrder

    build_for_select :mr_sales_order_items,
                     label: :remarks,
                     value: :id,
                     no_active_check: true,
                     order_by: :remarks

    crud_calls_for :mr_sales_order_items, name: :mr_sales_order_item, wrapper: MrSalesOrderItem

    build_for_select :sales_order_costs,
                     label: :id,
                     value: :id,
                     no_active_check: true,
                     order_by: :id

    crud_calls_for :sales_order_costs, name: :sales_order_cost, wrapper: SalesOrderCost

    def find_sales_order_cost(id)
      find_with_association(:sales_order_costs, id,
                            wrapper: SalesOrderCost,
                            parent_tables: [
                              {
                                parent_table: :mr_cost_types,
                                columns: [:cost_type_code],
                                flatten_columns: { cost_type_code: :cost_type_code }
                              }
                            ])
    end

    def find_mr_goods_returned_note(id)
      find_with_association(:mr_goods_returned_notes, id,
                            wrapper: MrGoodsReturnedNote,
                            parent_tables: [
                              { parent_table: :mr_deliveries,
                                columns: [:delivery_number],
                                flatten_columns: { delivery_number: :delivery_number } }
                            ],
                            lookup_functions: [
                              { function: :fn_current_status, args: ['mr_goods_returned_notes', :id], col_name: :status }
                            ])
    end

    def find_mr_sales_order(id)
      find_with_association(:mr_sales_orders, id,
                            wrapper: MrSalesOrder,
                            parent_tables: [
                              {
                                parent_table: :account_codes,
                                columns: [:account_code],
                                flatten_columns: { account_code: :account_code }
                              }
                            ],
                            lookup_functions: [
                              { function: :fn_current_status, args: ['mr_sales_orders', :id], col_name: :status }
                            ])
    end

    def find_mr_sales_order_item(id)
      find_with_association(:mr_sales_order_items, id,
                            wrapper: MrSalesOrderItem,
                            parent_tables: [
                              {
                                parent_table: :material_resource_product_variants,
                                foreign_key: :mr_product_variant_id,
                                columns: %i[product_variant_number product_variant_code],
                                flatten_columns: {
                                  product_variant_code: :product_variant_code,
                                  product_variant_number: :product_variant_number
                                }
                              }
                            ],
                            lookup_functions: [
                              { function: :fn_current_status, args: ['mr_sales_order_items', :id], col_name: :status }
                            ])
    end

    def create_mr_goods_returned_note_item(attrs)
      attrs = attrs.to_h
      if (batch_id = attrs[:mr_delivery_item_batch_id])
        item_id = DB[:mr_delivery_item_batches].where(id: batch_id).get(:mr_delivery_item_id)
        attrs[:mr_delivery_item_id] = item_id
      end
      create(:mr_goods_returned_note_items, attrs)
    end

    def find_mr_goods_returned_note_item(id)
      item = DB["SELECT mr_goods_returned_note_items.*,
                    coalesce(ms.sku_number, msk.sku_number) as sku_number,
                    material_resource_product_variants.product_variant_code,
                    material_resource_product_variants.product_variant_number,
                    fn_current_status('mr_goods_returned_note_items', mr_goods_returned_note_items.id) AS status,
                    mr_goods_returned_note_items.created_at,
                    mr_goods_returned_note_items.updated_at
                  FROM mr_goods_returned_note_items
                  LEFT JOIN mr_delivery_item_batches ON mr_delivery_item_batches.id = mr_goods_returned_note_items.mr_delivery_item_batch_id
                  LEFT JOIN mr_delivery_items ON mr_delivery_items.id = mr_goods_returned_note_items.mr_delivery_item_id
                  LEFT JOIN mr_deliveries on mr_deliveries.id = mr_delivery_items.mr_delivery_id
                  JOIN mr_goods_returned_notes ON mr_goods_returned_notes.id = mr_goods_returned_note_items.mr_goods_returned_note_id
                  LEFT JOIN mr_skus ms on mr_delivery_item_batches.id = ms.mr_delivery_item_batch_id
                  LEFT JOIN mr_skus msk on mr_delivery_items.mr_product_variant_id = msk.mr_product_variant_id
                  LEFT JOIN material_resource_product_variants on mr_delivery_items.mr_product_variant_id = material_resource_product_variants.id
                  WHERE mr_goods_returned_note_items.id = ?", id].first
      MrGoodsReturnedNoteItem.new(item)
    end

    def grn_item_hashes(grn_id)
      item_collection = []
      items = DB[:mr_goods_returned_note_items].where(mr_goods_returned_note_id: grn_id).all
      items.each do |item|
        batch_id = item[:mr_delivery_item_batch_id]
        record = batch_id ? DB[:mr_delivery_item_batches].where(id: batch_id) : DB[:mr_delivery_items].where(id: item[:mr_delivery_item_id])
        sku_id = record.get(:mr_sku_id)
        item_collection << item.merge(sku_id: sku_id)
      end
      item_collection
    end

    def grn_business_process_id
      DB[:business_processes].where(process: AppConst::PROCESS_GOODS_RETURN).get(:id)
    end

    def validate_grn_stock_levels(grn_id) # rubocop:disable Metrics/AbcSize
      grn = DB[:mr_goods_returned_notes].where(id: grn_id)
      item_collection = []
      grn_items = DB[:mr_goods_returned_note_items].where(mr_goods_returned_note_id: grn_id).all
      grn_items.each do |grn_item|
        record = delivery_item_record(grn_item[:id])
        sku_id = record.get(:mr_sku_id)
        qty_returned = grn_item[:quantity_returned]
        item_collection << { sku_id: sku_id, qty: qty_returned }
        avail_qty = DB[:mr_sku_locations].where(location_id: grn.get(:dispatch_location_id), mr_sku_id: sku_id).get(:quantity) || AppConst::BIG_ZERO
        next if avail_qty >= qty_returned

        return failed_response 'Stock to be shipped must be in the dispatch location'
      end
      success_response('OK', item_collection)
    end

    def dispatch_locations
      location_type_id = DB[:location_types].where(location_type_code: AppConst::LOCATION_TYPES_DISPATCH).get(:id)
      MasterfilesApp::LocationRepo.new.for_select_locations(where: { location_type_id: location_type_id, can_store_stock: true })
    end

    def goods_returned_note_item_options(grn_id) # rubocop:disable Metrics/AbcSize
      del_id = DB[:mr_goods_returned_notes].where(id: grn_id).get(:mr_delivery_id)
      items = DB[:mr_delivery_items].where(mr_delivery_id: del_id).all
      delivery = DB[:mr_deliveries].where(id: del_id).first
      collection = []
      items.each do |item|
        next if item[:grn_returned]

        batches = DB[:mr_delivery_item_batches].where(mr_delivery_item_id: item[:id]).all
        pv = DB[:material_resource_product_variants].where(id: item[:mr_product_variant_id]).first
        pv_number = pv[:product_variant_code]
        del_no = delivery[:delivery_number]
        if batches.any?
          batches.each do |r|
            next if r[:grn_returned]
            next if DB[:mr_goods_returned_note_items].where(
              mr_goods_returned_note_id: grn_id,
              mr_delivery_item_batch_id: r[:id]
            ).first

            qty = UtilityFunctions.delimited_number(r[:quantity_received], delimiter: '', no_decimals: 2)
            sku_number = DB[:mr_skus].where(id: r[:mr_sku_id]).get(:sku_number)
            collection << ["#{pv_number}, #{qty} (DEL:#{del_no}, SKU:#{sku_number})", "batch_#{r[:id]}"]
          end
        else
          unless DB[:mr_goods_returned_note_items].where(mr_goods_returned_note_id: grn_id, mr_delivery_item_id: item[:id]).first
            qty = UtilityFunctions.delimited_number(item[:quantity_received], delimiter: '', no_decimals: 2)
            sku_number = DB[:mr_skus].where(id: item[:mr_sku_id]).get(:sku_number)
            collection << ["#{pv_number}, #{qty} (DEL:#{del_no}, SKU:#{sku_number})", "item_#{item[:id]}"]
          end
        end
      end
      collection
    end

    def inline_update_goods_returned_note(id, attrs)
      update(:mr_goods_returned_note_items, id, "#{attrs[:column_name]}": attrs[:column_value])
    end

    def grn_complete_invoice(id, attrs)
      update(:mr_goods_returned_notes, id,
             invoice_error: false,
             invoice_completed: true,
             erp_purchase_order_number: attrs[:purchase_order_number],
             erp_purchase_invoice_number: attrs[:purchase_invoice_number])
    end

    def mark_as_shipped(grn_id)
      update(:mr_goods_returned_notes, grn_id, shipped: true)
    end

    def update_delivery_grn_status(del_id) # rubocop:disable Metrics/AbcSize
      delivery = DB[:mr_deliveries].where(id: del_id)
      grn_ids = DB[:mr_goods_returned_notes].where(mr_delivery_id: del_id, shipped: true).map(:id)
      item_ids = DB[:mr_delivery_items].where(mr_delivery_id: del_id).map(:id)
      batch_ids = DB[:mr_delivery_item_batches].where(mr_delivery_item_id: item_ids).map(:id)

      # Update batch qty's
      batch_ids.each do |batch_id|
        qty_returned = DB[:mr_goods_returned_note_items].where(mr_delivery_item_batch_id: batch_id, mr_goods_returned_note_id: grn_ids).sum(:quantity_returned)
        batch = DB[:mr_delivery_item_batches].where(id: batch_id)
        grn_returned = batch.get(:quantity_received) == qty_returned
        batch.update(grn_qty_returned: qty_returned, grn_returned: grn_returned)
      end

      # Update item qty's
      item_ids.each do |item_id|
        qty_returned = DB[:mr_goods_returned_note_items].where(mr_delivery_item_id: item_id, mr_goods_returned_note_id: grn_ids).sum(:quantity_returned)
        item = DB[:mr_delivery_items].where(id: item_id)
        grn_returned = item.get(:quantity_received) == qty_returned
        item.update(grn_qty_returned: qty_returned, grn_returned: grn_returned)
      end

      all_grn_returned = !DB[:mr_delivery_items].where(id: item_ids).map(:grn_returned).uniq.include?(false)
      delivery.update(grn_returned: true) if item_ids && all_grn_returned
    end

    def validate_grn_quantity_amount(grn_item_id, attrs)
      new_qty = BigDecimal(attrs[:column_value]) || attrs[:quantity_returned]
      record = delivery_item_record(grn_item_id)
      return failed_response('Item has already been returned in full') if record.get(:grn_returned)

      avail_qty = record.get(:quantity_received) - record.get(:grn_qty_returned)
      return failed_response("Quantity available: #{UtilityFunctions.delimited_number(avail_qty)}") unless new_qty <= avail_qty

      success_response('valid quantity')
    end

    def delivery_item_record(grn_item_id)
      grn_item = DB[:mr_goods_returned_note_items].where(id: grn_item_id)
      batch_id = grn_item.get(:mr_delivery_item_batch_id)
      batch_id ? DB[:mr_delivery_item_batches].where(id: batch_id) : DB[:mr_delivery_items].where(id: grn_item.get(:mr_delivery_item_id))
    end

    def get_mrpv_info(mrpv_id)
      mrpv = DB[:material_resource_product_variants].where(id: mrpv_id).first
      {
        pv_code: mrpv[:product_variant_code],
        pv_number: mrpv[:product_variant_number],
        pv_wa_cost: mrpv[:weighted_average_cost].to_s
      }
    end

    def inline_update_sales_order_item(id, attrs)
      update(:mr_sales_order_items, id, unit_price: attrs[:column_value])
    end

    def validate_mr_sales_order_item_quantity_required(attrs)
      requested_qty = attrs[:quantity_required]
      sku_ids = DB[:mr_skus].where(mr_product_variant_id: attrs[:mr_product_variant_id]).select_map(:id)
      # pv = DB[:material_resource_product_variants].where(id: attrs[:mr_product_variant_id]).first
      stock = DB[:mr_sku_locations].where(mr_sku_id: sku_ids)
      # NOTE: We might want to exclude consignment stock here
      actual_qty = stock.sum(:quantity)
      return failed_response('We do not have this product in stock') unless actual_qty&.positive?

      return failed_response("Quantity available: #{UtilityFunctions.delimited_number(actual_qty)}") unless requested_qty <= actual_qty

      success_response('valid quantity')
    end

    def validate_sales_stock_levels(so_id) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      dispatch_location_id = DB[:mr_sales_orders].where(id: so_id).get(:dispatch_location_id)
      return failed_response('No dispatch location') unless dispatch_location_id

      items = DB[:mr_sales_order_items].where(mr_sales_order_id: so_id).all
      return failed_response('No Sales Order Items') if items.none?

      item_collection = []
      items.each do |item|
        so_item = find_mr_sales_order_item(item[:id])
        mrpv_id = item[:mr_product_variant_id]
        qty = item[:quantity_required]
        sku_ids = DB[:mr_skus].where(mr_product_variant_id: mrpv_id).select_map(:id)
        stock_items = DB[:mr_sku_locations].order_by(:quantity).where(location_id: dispatch_location_id, mr_sku_id: sku_ids).all
        return failed_response("No stock for #{so_item.product_variant_code} at dispatch location.") if stock_items.none?

        collection = []
        qty_to_dispatch = 0
        stock_items.each do |sku_loc|
          qty_needed = qty - qty_to_dispatch
          next unless qty_needed.positive?

          qty_used = qty_needed <= sku_loc[:quantity] ? qty_needed : sku_loc[:quantity]
          collection << { sku_id: sku_loc[:mr_sku_id], qty: qty_used, mrpv_id: mrpv_id }
          qty_to_dispatch += qty_used
        end
        fulfilled = collection.map { |r| r[:qty] }.sum == qty
        return failed_response("Not enough stock for #{so_item.product_variant_code}") unless fulfilled

        item_collection << collection
      end
      success_response('OK', item_collection.flatten)
    end

    def sales_order_business_process_id
      DB[:business_processes].where(process: AppConst::PROCESS_SALES_ORDERS).get(:id)
    end

    def create_mr_sales_order(attrs)
      customer = DB[:customers].where(party_role_id: attrs[:customer_party_role_id]).first
      create(:mr_sales_orders, attrs.merge(erp_customer_number: customer[:erp_customer_number]))
    end

    def create_mr_sales_order_item(attrs)
      wa_cost = DB[:material_resource_product_variants].where(id: attrs[:mr_product_variant_id]).get(:weighted_average_cost)
      create(:mr_sales_order_items, attrs.to_h.merge(unit_price: wa_cost))
    end

    def so_sub_totals(id, opts = {})
      subtotal = so_total_items(id)
      costs = so_total_costs(id)
      vat = so_total_vat(id, subtotal + costs)
      {
        subtotal: UtilityFunctions.delimited_number(subtotal, opts),
        costs: UtilityFunctions.delimited_number(costs, opts),
        vat: UtilityFunctions.delimited_number(vat, opts),
        total: UtilityFunctions.delimited_number(subtotal + costs + vat, opts)
      }
    end

    def so_total_items(id)
      DB['SELECT SUM(quantity_required * unit_price) AS total FROM mr_sales_order_items WHERE mr_sales_order_id = ?', id].single_value || AppConst::BIG_ZERO
    end

    def so_total_vat(id, subtotal)
      return AppConst::BIG_ZERO if subtotal.zero?

      mr_vat_type_id = DB[:mr_sales_orders].where(id: id).get(:vat_type_id)
      factor = DB[:mr_vat_types].where(id: mr_vat_type_id).get(Sequel[:mr_vat_types][:percentage_applicable]./100.0) || AppConst::BIG_ZERO
      subtotal * factor
    end

    def so_total_costs(id)
      DB[:sales_order_costs].where(mr_sales_order_id: id).sum(:amount) || AppConst::BIG_ZERO
    end

    def so_costs(mr_sales_order_id)
      DB[:sales_order_costs].join(:mr_cost_types, id: :mr_cost_type_id)
                            .where(mr_sales_order_id: mr_sales_order_id)
                            .select(:cost_type_code, :amount, :account_code).all
    end

    def products_for_sales_order(mr_sales_order_id)
      DB[:mr_sales_order_items]
        .join(:material_resource_product_variants, id: :mr_product_variant_id)
        .where(mr_sales_order_id: mr_sales_order_id)
        .select(:quantity_required,
                :unit_price,
                :product_variant_code,
                :weighted_average_cost,
                (Sequel[:mr_sales_order_items][:quantity_required] * Sequel[:mr_sales_order_items][:unit_price]).as(:line_total))
        .all
    end

    def so_complete_invoice(id, attrs)
      update(:mr_sales_orders, id,
             integration_error: false,
             integration_completed: true,
             erp_profit_loss_number: attrs[:journal_number],
             erp_invoice_number: attrs[:sales_invoice_number])
    end

    def update_weighted_average_costs(grn_id)
      items = DB[:mr_delivery_items].where(mr_delivery_id: DB[:mr_goods_returned_notes].where(id: grn_id).get(:mr_delivery_id)).all
      items.each do |item|
        WaCostRepo.new.update_wa_cost(item[:mr_product_variant_id])
      end
    end
  end
end
