# frozen_string_literal: true

module PackMaterialApp
  class ReplenishRepo < BaseRepo
    build_for_select :mr_purchase_orders,
                     label: :purchase_order_number,
                     value: :id,
                     no_active_check: true,
                     order_by: :purchase_order_number

    crud_calls_for :mr_purchase_orders, name: :mr_purchase_order, wrapper: MrPurchaseOrder

    build_for_select :mr_delivery_terms,
                     label: :delivery_term_code,
                     value: :id,
                     no_active_check: true,
                     order_by: :delivery_term_code

    crud_calls_for :mr_delivery_terms, name: :mr_delivery_term, wrapper: MrDeliveryTerm

    build_for_select :mr_vat_types,
                     label: :vat_type_code,
                     value: :id,
                     no_active_check: true,
                     order_by: :vat_type_code

    crud_calls_for :mr_vat_types, name: :mr_vat_type, wrapper: MrVatType

    build_for_select :mr_cost_types,
                     label: :cost_code_string,
                     value: :id,
                     no_active_check: true,
                     order_by: :cost_code_string

    crud_calls_for :mr_cost_types, name: :mr_cost_type, wrapper: MrCostType

    build_for_select :mr_purchase_order_items,
                     label: :mr_product_variant_id,
                     alias: 'raw_mr_purchase_order_items',
                     value: :id,
                     no_active_check: true,
                     order_by: :id

    crud_calls_for :mr_purchase_order_items, name: :mr_purchase_order_item, wrapper: MrPurchaseOrderItem

    build_for_select :mr_purchase_order_costs,
                     label: :id,
                     value: :id,
                     no_active_check: true,
                     order_by: :id

    crud_calls_for :mr_purchase_order_costs, name: :mr_purchase_order_cost, wrapper: MrPurchaseOrderCost

    build_for_select :mr_deliveries,
                     label: :driver_name,
                     value: :id,
                     no_active_check: true,
                     order_by: :driver_name

    crud_calls_for :mr_deliveries, name: :mr_delivery, wrapper: MrDelivery

    build_for_select :mr_delivery_items,
                     label: :remarks,
                     value: :id,
                     no_active_check: true,
                     order_by: :remarks

    crud_calls_for :mr_delivery_items, name: :mr_delivery_item, wrapper: MrDeliveryItem

    build_for_select :mr_delivery_item_batches,
                     label: :client_batch_number,
                     value: :id,
                     no_active_check: true,
                     order_by: :client_batch_number

    crud_calls_for :mr_delivery_item_batches, name: :mr_delivery_item_batch, wrapper: MrDeliveryItemBatch

    def find_mr_purchase_order(id)
      find_with_association(:mr_purchase_orders, id,
                            lookup_functions: [{ function: :fn_current_status,
                                                 args: ['mr_purchase_orders', :id],
                                                 col_name: :status }],
                            wrapper: MrPurchaseOrder)
    end

    def find_mr_purchase_order_cost(id)
      find_with_association(:mr_purchase_order_costs, id,
                            parent_tables: [{ parent_table: :mr_cost_types, flatten_columns: { cost_code_string: :cost_type } }],
                            wrapper: MrPurchaseOrderCost)
    end

    def find_mr_purchase_order_item(id)
      find_with_association(:mr_purchase_order_items, id,
                            parent_tables: [{ parent_table: :material_resource_product_variants, flatten_columns: { product_variant_code: :product_variant_code }, foreign_key: :mr_product_variant_id },
                                            { parent_table: :uoms, flatten_columns: { uom_code: :purchasing_uom_code }, foreign_key: :purchasing_uom_id },
                                            { parent_table: :uoms, flatten_columns: { uom_code: :inventory_uom_code }, foreign_key: :inventory_uom_id }],
                            wrapper: MrPurchaseOrderItem)
    end

    def for_select_suppliers
      valid_supplier_ids = DB[:material_resource_product_variant_party_roles].distinct.select_map(:supplier_id).compact
      MasterfilesApp::PartyRepo.new.for_select_suppliers.select { |r| valid_supplier_ids.include?(r[1]) }
    end

    # Only product variants that have suppliers and are not already set up for this purchase order id
    #
    # @return [Array] ['Product Variant Code', :id]
    # @param [Integer] purchase_order_id
    def for_select_po_product_variants(purchase_order_id) # rubocop:disable Metrics/AbcSize
      role_id = DB[:mr_purchase_orders].where(id: purchase_order_id).select_map(:supplier_party_role_id).first
      supplier_id = DB[:suppliers].where(party_role_id: role_id).single_value
      product_variants = DB[:material_resource_product_variants].where(
        id: DB[:material_resource_product_variant_party_roles].where(
          supplier_id: supplier_id
        ).select_map(:material_resource_product_variant_id)
      ).reject do |r|
        DB[:mr_purchase_order_items].where(mr_purchase_order_id: purchase_order_id)
                                    .select_map(:mr_product_variant_id).include?(r[:id])
      end
      product_variants.map { |r| [r[:product_variant_code], r[:id]] }
    end

    # @return [Array] ['Purchase Order Number - from: Supplier Party Name', :id]
    def for_select_purchase_orders_with_supplier(purchase_order_id: nil)
      if purchase_order_id
        supplier_id = DB[:mr_purchase_orders].where(id: purchase_order_id).get(:supplier_party_role_id)
        purchase_orders = DB[:mr_purchase_orders].where(approved: true, supplier_party_role_id: supplier_id)
      else
        purchase_orders = DB[:mr_purchase_orders].where(approved: true)
      end
      purchase_orders.select(
        :id,
        :purchase_order_number,
        Sequel.function(:fn_party_role_name, :supplier_party_role_id)
      ).map { |r| [[r[:purchase_order_number], r[:fn_party_role_name]].join(' - from: '), r[:id]] }
    end

    # @return [Array] returns for select with association label name
    def for_select_mr_purchase_order_items(purchase_order_id)
      for_select_raw_mr_purchase_order_items(
        where: { mr_purchase_order_id: purchase_order_id }
      ).map { |r| [DB[:material_resource_product_variants].where(id: r[0]).get(:product_variant_code), r[1]] }
    end

    def for_select_remaining_purchase_order_items(purchase_order_id, delivery_id)
      used_po_item_ids = DB[:mr_delivery_items].where(mr_delivery_id: delivery_id).select_map(:mr_purchase_order_item_id)
      for_select_mr_purchase_order_items(purchase_order_id).reject { |r| used_po_item_ids.include?(r[1]) }
    end

    def purchase_order_id_for_delivery_item(mr_delivery_item_id)
      DB[:mr_purchase_order_items].where(
        id: DB[:mr_delivery_items].where(
          id: mr_delivery_item_id
        ).select(:mr_purchase_order_item_id)
      ).get(:mr_purchase_order_id)
    end

    def sub_totals(id)
      subtotal = po_total_items(id)
      costs = po_total_costs(id)
      vat = po_total_vat(id, subtotal)
      {
        subtotal: UtilityFunctions.delimited_number(subtotal),
        costs: UtilityFunctions.delimited_number(costs),
        vat: UtilityFunctions.delimited_number(vat),
        total: UtilityFunctions.delimited_number(subtotal + costs + vat)
      }
    end

    def po_total_items(id)
      DB['SELECT SUM(quantity_required * unit_price) AS total FROM mr_purchase_order_items WHERE mr_purchase_order_id = ?', id].single_value || BigDecimal('0')
    end

    def po_total_costs(id)
      DB[:mr_purchase_order_costs].where(mr_purchase_order_id: id).sum(:amount) || BigDecimal('0')
    end

    def po_total_vat(id, subtotal)
      return BigDecimal('0') if subtotal.zero?
      factor = DB['SELECT percentage_applicable / 100.0 AS vat_factor FROM mr_vat_types WHERE id = (SELECT mr_vat_type_id FROM mr_purchase_orders WHERE id = ?)', id].single_value || BigDecimal('0')
      subtotal * factor
    end

    def mr_purchase_order_items(mr_purchase_order_id)
      DB[:mr_purchase_order_items].where(mr_purchase_order_id: mr_purchase_order_id).select_map(:id)
    end

    def find_mr_delivery(id)
      find_with_association(:mr_deliveries, id,
                            lookup_functions: [{ function: :fn_party_role_name,
                                                 args: [:transporter_party_role_id],
                                                 col_name: :transporter },
                                               { function: :fn_current_status,
                                                 args: ['mr_deliveries', :id],
                                                 col_name: :status }],
                            wrapper: MrDelivery)
    end

    def verify_mr_delivery(id)
      update(:mr_deliveries, id, verified: true)
    end

    def mr_delivery_items(mr_delivery_id)
      DB[:mr_delivery_items].where(mr_delivery_id: mr_delivery_id).select_map(:id)
    end

    def items_without_batches(mr_delivery_id)
      DB[:mr_delivery_items].where(mr_delivery_id: mr_delivery_id).map(:id).each do |item_id|
        next if item_has_fixed_batch(item_id)
        has_batch = DB[:mr_delivery_item_batches].where(mr_delivery_item_id: item_id).get(:id)
        return true unless has_batch
      end
      false
    end

    def item_has_fixed_batch(delivery_item_id)
      DB[:material_resource_product_variants].where(
        id: DB[:mr_delivery_items].where(
          id: delivery_item_id
        ).get(:mr_product_variant_id)
      ).get(:use_fixed_batch_number)
    end

    def delivery_item_batches(mr_delivery_item_id)
      where(:mr_delivery_item_batches, MrDeliveryItemBatch, mr_delivery_item_id: mr_delivery_item_id)
    end

    def batch_quantities_match(mr_delivery_id)
      DB[:mr_delivery_items].where(mr_delivery_id: mr_delivery_id).all.each do |item|
        next if item_has_fixed_batch(item[:id])
        batch_quantities = DB[:mr_delivery_item_batches].where(mr_delivery_item_id: item[:id]).sum(:quantity_on_note)
        quantities_match = item[:quantity_on_note] == batch_quantities
        return false unless quantities_match
      end
      true
    end

    def delete_mr_delivery(mr_delivery_id)
      item_ids = DB[:mr_delivery_items].where(mr_delivery_id: mr_delivery_id).select_map(:id)
      item_ids.each do |item_id|
        delete_mr_delivery_item(item_id)
      end
      delete(:mr_deliveries, mr_delivery_id)
    end

    def delete_mr_delivery_item(mr_delivery_item_id)
      DB[:mr_delivery_item_batches].where(mr_delivery_item_id: mr_delivery_item_id).delete
      delete(:mr_delivery_items, mr_delivery_item_id)
    end

    def sku_id_for_delivery_item_batch(mr_delivery_item_batch_id)
      DB[:mr_skus].where(mr_delivery_item_batch_id: mr_delivery_item_batch_id).get(:id)
    end

    def sku_id_for_delivery_item(delivery_item_id)
      item_batches = DB[:mr_delivery_item_batches].where(mr_delivery_item_id: delivery_item_id).all
      return nil if item_batches.any?
      pv_id = DB[:mr_delivery_items].where(id: delivery_item_id).get(:mr_product_variant_id)
      int_batch_id = DB[:material_resource_product_variants].where(id: pv_id).get(:mr_internal_batch_number_id)
      DB[:mr_skus].where(
        mr_internal_batch_number_id: int_batch_id,
        mr_product_variant_id: pv_id
      ).get(:id)
    end

    def sku_for_barcode(sku_id: nil, mr_delivery_item_id: nil, mr_delivery_item_batch_id: nil)
      return nil unless (sku_id || mr_delivery_item_id || mr_delivery_item_batch_id)
      info = nil
      info = sku_info_from_batch_id(mr_delivery_item_batch_id) if mr_delivery_item_batch_id
      info = sku_info_from_item_id(mr_delivery_item_id) if mr_delivery_item_id
      info = sku_info_from_sku_id(sku_id) if sku_id
      info
    end

    def sku_info_from_batch_id(mr_delivery_item_batch_id)
      batch = DB[:mr_delivery_item_batches].where(id: mr_delivery_item_batch_id)
      batch_number = batch.get(:client_batch_number)

      item_id = batch.get(:mr_delivery_item_id)
      item = DB[:mr_delivery_items].where(id: item_id)

      pv = DB[:material_resource_product_variants].where(id: item.get(:mr_product_variant_id))
      pv_code = pv.get(:product_variant_code)

      sku = DB[:mr_skus].where(mr_delivery_item_batch_id: mr_delivery_item_batch_id,
                               mr_product_variant_id: item.get(:mr_product_variant_id))
      sku_number = sku.get(:sku_number)
      delivery_number = DB[:mr_deliveries].where(id: item.get(:mr_delivery_id)).get(:delivery_number)
      no_of_prints = batch.get(:quantity_received) - batch.get(:quantity_putaway)
      no_of_prints = 1 if no_of_prints.zero? || no_of_prints.negative?
      {
        sku_number: sku_number,
        product_variant_code: pv_code,
        batch_number: batch_number,
        no_of_prints: no_of_prints,
        delivery_number: delivery_number
      }
    end

    def sku_info_from_item_id(mr_delivery_item_id)
      item = DB[:mr_delivery_items].where(id: mr_delivery_item_id)

      pv = DB[:material_resource_product_variants].where(id: item.get(:mr_product_variant_id))
      pv_code = pv.get(:product_variant_code)

      batch_number = DB[:mr_internal_batch_numbers].where(id: pv.get(:mr_internal_batch_number_id)).get(:batch_number)

      sku = DB[:mr_skus].where(mr_internal_batch_number_id: pv.get(:mr_internal_batch_number_id),
                               mr_product_variant_id: item.get(:mr_product_variant_id))
      sku_number = sku.get(:sku_number)
      delivery_number = DB[:mr_deliveries].where(id: item.get(:mr_delivery_id)).get(:delivery_number)
      no_of_prints = item.get(:quantity_received) - item.get(:quantity_putaway)
      no_of_prints = 1 if no_of_prints.zero? || no_of_prints.negative?
      {
        sku_number: sku_number,
        product_variant_code: pv_code,
        batch_number: batch_number,
        no_of_prints: no_of_prints,
        delivery_number: delivery_number
      }
    end

    def sku_info_from_sku_id(sku_id)
      sku = DB[:mr_skus].where(id: sku_id).first
      no_of_prints = 0
      delivery_number = nil
      if (item_batch_id = sku[:mr_delivery_item_batch_id])
        batch = DB[:mr_delivery_item_batches].where(id: item_batch_id)
        item = DB[:mr_delivery_items].where(id: batch.get(:mr_delivery_item_id))
        delivery_number = DB[:mr_deliveries].where(id: item.get(:mr_delivery_id)).get(:delivery_number)
        batch_number = DB[:mr_delivery_item_batches].where(id: item_batch_id).get(:client_batch_number)
        no_of_prints = batch.get(:quantity_received) - batch.get(:quantity_putaway)
      else
        batch_number = DB[:mr_internal_batch_numbers].where(id: sku[:mr_internal_batch_number_id]).get(:batch_number)
      end
      pv_code = DB[:material_resource_product_variants].where(id: sku[:mr_product_variant_id]).get(:product_variant_code)
      sku_number = sku[:sku_number]
      no_of_prints = 1 if no_of_prints.zero? || no_of_prints.negative?
      {
        sku_number: sku_number,
        product_variant_code: pv_code,
        batch_number: batch_number,
        no_of_prints: no_of_prints,
        delivery_number: delivery_number
      }
    end

    def resolve_location_id_from_scan(val, scan_field)
      case scan_field
      when 'location_code'
        location_id_from_location_code(val)
      when 'location_legacy_barcode'
        location_id_from_legacy_barcode(val)
      else
        val
      end
    end

    def location_id_from_legacy_barcode(value)
      DB[:locations].where(legacy_barcode: value).get(:id)
    end

    def location_id_from_location_code(value)
      DB[:locations].where(location_code: value).get(:id)
    end

    def location_code_from_location_id(location_id)
      DB[:locations].where(id: location_id).get(:location_code)
    end

    def sku_ids_from_numbers(values)
      DB[:mr_skus].where(sku_number: values).map(:id)
    end

    def delivery_id_from_number(delivery_number)
      DB[:mr_deliveries].where(delivery_number: delivery_number).get(:id)
    end

    def delivery_number_from_id(delivery_id)
      DB[:mr_deliveries].where(id: delivery_id).get(:delivery_number)
    end

    def sku_number_from_id(sku_id)
      DB[:mr_skus].where(id: sku_id).get(:sku_number)
    end

    def delivery_putaway_reaction_job(sku_id, quantity, delivery_id)
      res = update_delivery_putaway_quantity(sku_id, quantity, delivery_id)
      return res unless res.success
      update_delivery_putaway_statuses(delivery_id)
      sku = DB[:mr_skus].where(id: sku_id)
      po_item_id = DB[:mr_delivery_items].where(
        mr_product_variant_id: sku.get(:mr_product_variant_id),
        mr_delivery_id: delivery_id
      ).get(:mr_purchase_order_item_id)
      update_purchase_order_statuses(po_item_id)
      success_response('ok')
    end

    def update_delivery_putaway_quantity(sku_id, quantity, delivery_id)
      sku = DB[:mr_skus].where(id: sku_id)
      pv_id = sku.get(:mr_product_variant_id)
      item = DB[:mr_delivery_items].where(mr_delivery_id: delivery_id, mr_product_variant_id: pv_id)
      return failed_response('SKU does not belong to delivery') unless item.first

      fixed = DB[:material_resource_product_variants].where(id: pv_id).get(:use_fixed_batch_number)
      unless fixed
        batch_id = sku.get(:mr_delivery_item_batch_id)
        batch = DB[:mr_delivery_item_batches].where(id: batch_id) if batch_id
        batch_qty = batch.get(:quantity_putaway)
        batch_qty += quantity
        batch.update(quantity_putaway: batch_qty)

        if batch.get(:quantity_received) <= batch_qty
          batch.update(putaway_completed: true)
          log_status('mr_delivery_item_batches', batch_id, 'PUTAWAY_COMPLETED')
        end
      end

      item = DB[:mr_delivery_items].where(mr_delivery_id: delivery_id, mr_product_variant_id: pv_id)
      qty = item.get(:quantity_putaway)
      qty += quantity
      item.update(quantity_putaway: qty)

      if item.get(:quantity_received) <= qty
        item.update(putaway_completed: true)
        log_status('mr_delivery_items', item.get(:id), 'PUTAWAY_COMPLETED')
      end
      success_response('ok')
    end

    def update_delivery_putaway_statuses(delivery_id)
      putaway_completed = DB[:mr_deliveries].where(id: delivery_id).get(:putaway_completed)
      return failed_response('ERROR: Delivery putaway already completed') if putaway_completed

      items = DB[:mr_delivery_items].where(mr_delivery_id: delivery_id)
      statuses = items.map do |r|
        DB[Sequel.function(:fn_current_status, 'mr_delivery_items', r[:id])].single_value
      end

      if statuses.all?('PUTAWAY_COMPLETED')
        DB[:mr_deliveries].where(id: delivery_id).update(putaway_completed: true)
        log_status('mr_deliveries', delivery_id, 'DELIVERY_OFFLOADED')
      else
        log_status('mr_deliveries', delivery_id, 'OFFLOADING_DELIVERY')
      end
      success_response('ok')
    end

    def update_purchase_order_statuses(po_item_id)
      po_item = DB[:mr_purchase_order_items].where(id: po_item_id)
      qty_required = po_item.get(:quantity_required)
      items = DB[:mr_delivery_items].where(mr_purchase_order_item_id: po_item_id)
      po = DB[:mr_purchase_orders].where(id: po_item.get(:mr_purchase_order_id)).first

      if items.sum(:quantity_putaway) >= qty_required
        log_status('mr_purchase_order_items', po_item_id, 'PO_ITEM_RECEIVED')
        po_items = DB[:mr_purchase_order_items].where(mr_purchase_order_id: po[:id])
        po_item_statuses = po_items.map do |r|
          DB[Sequel.function(:fn_current_status, 'mr_purchase_order_items', r[:id])].single_value
        end

        if po_item_statuses.all?('PO_ITEM_RECEIVED')
          DB[:mr_purchase_orders].where(id: po[:id]).update(deliveries_received: true)
          log_status('mr_purchase_orders', po[:id], 'PURCHASE_ORDER_CLOSED')
        else
          log_status('mr_purchase_orders', po[:id], 'RECEIVING_DELIVERIES')
        end
      else
        log_status('mr_purchase_order_items', po_item_id, 'PO_ITEM_RECEIVING')
        log_status('mr_purchase_orders', po[:id], 'RECEIVING_DELIVERIES')
      end
    end

    def html_delivery_progress_report(delivery_id, sku_id, to_location_id)
      return nil unless delivery_id && sku_id && to_location_id
      total_items = DB[:mr_delivery_items].where(mr_delivery_id: delivery_id).all
      done = total_items.select { |r| r[:quantity_putaway].to_f >= r[:quantity_received].to_f }.count
      sku = DB[:mr_skus].where(id: sku_id).first
      product_variant_code = DB[:material_resource_product_variants].where(id: sku[:mr_product_variant_id]).get(:product_variant_code)
      item = DB[:mr_delivery_items].where(mr_product_variant_id: sku[:mr_product_variant_id], mr_delivery_id: delivery_id)
      <<~HTML
        Delivery (#{delivery_number_from_id(delivery_id)}): #{done} of #{total_items.count} items.<br>
        Last scan:<br>
        LOC: #{location_code_from_location_id(to_location_id)}<br>
        SKU (#{sku_number_from_id(sku_id)}): #{product_variant_code}<br>
        #{item.get(:quantity_putaway).to_i} of #{item.get(:quantity_received).to_i} items.<br>
      HTML
    end
  end
end
