# frozen_string_literal: true

module PackMaterialApp
  class ReplenishRepo < BaseRepo # rubocop:disable Metrics/ClassLength
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
                     label: :cost_type_code,
                     value: :id,
                     no_active_check: true,
                     order_by: :cost_type_code

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
                     label: :delivery_number,
                     value: :id,
                     no_active_check: true,
                     order_by: :delivery_number

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

    build_for_select :mr_purchase_invoice_costs,
                     label: :id,
                     value: :id,
                     no_active_check: true,
                     order_by: :id

    crud_calls_for :mr_purchase_invoice_costs, name: :mr_purchase_invoice_cost, wrapper: MrPurchaseInvoiceCost

    def for_select_delivery_terms_with_descriptions
      DB["SELECT mr_delivery_terms.id,
                 concat(delivery_term_code, ' (', description, ')') as desc
        from mr_delivery_terms"].all.map { |r| [r[:desc], r[:id]] }
    end

    def find_mr_delivery_item(id)
      hash = find_hash(:mr_delivery_items, id)
      amt = hash[:quantity_under_supplied]&.positive? ? -1 * hash[:quantity_under_supplied] : hash[:quantity_over_supplied]
      hash[:quantity_over_under_supplied] = amt || AppConst::BIG_ZERO
      MrDeliveryItem.new(hash)
    end

    def find_mr_purchase_order(id)
      find_with_association(:mr_purchase_orders, id,
                            parent_tables: [{ parent_table: :account_codes, flatten_columns: { account_code: :purchase_account_code } }],
                            lookup_functions: [{ function: :fn_current_status,
                                                 args: ['mr_purchase_orders', :id],
                                                 col_name: :status }],
                            wrapper: MrPurchaseOrder)
    end

    def delete_mr_purchase_order(id)
      DB[:mr_purchase_order_costs].where(mr_purchase_order_id: id).delete
      DB[:mr_purchase_order_items].where(mr_purchase_order_id: id).delete
      delete(:mr_purchase_orders, id)
    end

    def find_mr_purchase_order_cost(id)
      find_with_association(:mr_purchase_order_costs, id,
                            parent_tables: [{ parent_table: :mr_cost_types, flatten_columns: { cost_type_code: :cost_type } }],
                            wrapper: MrPurchaseOrderCost)
    end

    def find_mr_purchase_invoice_cost(id)
      find_with_association(:mr_purchase_invoice_costs, id,
                            parent_tables: [{ parent_table: :mr_cost_types, flatten_columns: { cost_type_code: :cost_type } }],
                            wrapper: MrPurchaseInvoiceCost)
    end

    def find_mr_purchase_order_item(id)
      find_with_association(:mr_purchase_order_items, id,
                            parent_tables: [{ parent_table: :material_resource_product_variants, flatten_columns: { product_variant_code: :product_variant_code }, foreign_key: :mr_product_variant_id },
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
      purchase_orders_ds(purchase_order_id)
        .order(:purchase_order_number)
        .select(
          :id,
          :purchase_order_number,
          Sequel.function(:fn_party_role_name, :supplier_party_role_id)
        )
        .map { |r| [[r[:purchase_order_number], r[:fn_party_role_name]].join(' - from: '), r[:id]] }
    end

    def purchase_orders_ds(purchase_order_id)
      if purchase_order_id
        supplier_id = DB[:mr_purchase_orders].where(id: purchase_order_id).get(:supplier_party_role_id)
        DB[:mr_purchase_orders].where(approved: true, supplier_party_role_id: supplier_id, deliveries_received: false)
      else
        DB[:mr_purchase_orders].where(approved: true, deliveries_received: false)
      end
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

    def po_sub_totals(id)
      subtotal = po_total_items(id)
      costs = po_total_costs(id)
      vat = po_total_vat(id, subtotal + costs)
      {
        subtotal: UtilityFunctions.delimited_number(subtotal),
        costs: UtilityFunctions.delimited_number(costs),
        vat: UtilityFunctions.delimited_number(vat),
        total: UtilityFunctions.delimited_number(subtotal + costs + vat)
      }
    end

    def po_total_items(id)
      DB['SELECT SUM(quantity_required * unit_price) AS total FROM mr_purchase_order_items WHERE mr_purchase_order_id = ?', id].single_value || AppConst::BIG_ZERO
    end

    def po_total_costs(id)
      DB[:mr_purchase_order_costs].where(mr_purchase_order_id: id).sum(:amount) || AppConst::BIG_ZERO
    end

    def po_total_vat(id, subtotal)
      return AppConst::BIG_ZERO if subtotal.zero?

      factor = po_vat_factor(id)
      subtotal * factor
    end

    def po_vat_factor(po_id)
      DB[:mr_vat_types].join(:mr_purchase_orders, mr_vat_type_id: :id)
                       .where(Sequel[:mr_purchase_orders][:id] => po_id)
                       .get(Sequel[:mr_vat_types][:percentage_applicable]./100.0) || AppConst::BIG_ZERO
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

    def purchase_order_numbers_for_delivery(delivery_id)
      DB[:mr_purchase_orders].where(
        id: DB[:mr_purchase_order_items].where(
          id: DB[:mr_delivery_items].where(
            mr_delivery_id: delivery_id
          ).select_map(:mr_purchase_order_item_id)
        ).select_map(:mr_purchase_order_id)
      ).select_map(:purchase_order_number).join('; ')
    end

    def verify_mr_delivery(id)
      update(:mr_deliveries, id, verified: true)
    end

    def review_mr_delivery(id)
      waybill_no = DB[:mr_deliveries].where(id: id).get(:waybill_number)
      update(:mr_deliveries, id, reviewed: true)
      update(:mr_deliveries, id, accepted_over_supply: true) if items_with_over_supply(id)
      update(:mr_deliveries, id, accepted_qty_difference: true) if items_with_qty_difference(id)
      update_with_document_number('doc_seqs_waybill_number', id) unless waybill_no
    end

    def delivery_complete_invoice(id, attrs)
      update(:mr_deliveries, id,
             invoice_error: false,
             invoice_completed: true,
             erp_purchase_order_number: attrs[:purchase_order_number],
             erp_purchase_invoice_number: attrs[:purchase_invoice_number])
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

    def items_with_over_supply(mr_delivery_id)
      DB[:mr_delivery_items].where(mr_delivery_id: mr_delivery_id).where { quantity_over_supplied > 0 }.get(:id) # rubocop:disable Style/NumericPredicate
    end

    def items_with_qty_difference(mr_delivery_id)
      DB[:mr_delivery_items].where(mr_delivery_id: mr_delivery_id).where { quantity_difference > 0 }.get(:id) # rubocop:disable Style/NumericPredicate
    end

    def item_has_fixed_batch(delivery_item_id)
      DB[:material_resource_product_variants].where(
        id: DB[:mr_delivery_items].where(
          id: delivery_item_id
        ).get(:mr_product_variant_id)
      ).get(:use_fixed_batch_number)
    end

    def items_without_prices(mr_delivery_id)
      items = DB[:mr_delivery_items].where(mr_delivery_id: mr_delivery_id).map(:invoiced_unit_price)
      items.include?(nil)
    end

    def incomplete_items(mr_delivery_id) # rubocop:disable Metrics/AbcSize
      items = DB[:mr_delivery_items].where(mr_delivery_id: mr_delivery_id)
      batches = DB[:mr_delivery_item_batches].where(mr_delivery_item_id: items.map(:id))
      item_check = items.map { |r| [r[:quantity_on_note], r[:quantity_received]] }.flatten
      batch_check = batches.map { |r| [r[:quantity_on_note], r[:quantity_received]] }.flatten
      all_items = item_check + batch_check
      (all_items & [nil, 0]).any?
    end

    def invalid_on_consignment_items(mr_delivery_id)
      items = DB[:mr_delivery_items].where(mr_delivery_id: mr_delivery_id).map { |r| invalid_on_consignment_item(r[:id]) }
      items.include?(true)
    end

    def on_consignment_items(mr_delivery_id)
      DB[:mr_delivery_items].where(mr_delivery_id: mr_delivery_id).map { |r| item_on_consignment(r[:id]) }.include?(true)
    end

    def item_on_consignment(mr_delivery_item_id)
      DB[:mr_purchase_orders].where(
        id: DB[:mr_purchase_order_items].where(
          id: DB[:mr_delivery_items].where(
            id: mr_delivery_item_id
          ).get(:mr_purchase_order_item_id)
        ).get(:mr_purchase_order_id)
      ).get(:is_consignment_stock)
    end

    def invalid_on_consignment_item(mr_delivery_item_id)
      item_on_consignment(mr_delivery_item_id) && delivery_item_batches(mr_delivery_item_id).none?
    end

    def delivery_item_batches(mr_delivery_item_id)
      DB[:mr_delivery_item_batches].where(mr_delivery_item_id: mr_delivery_item_id).all
    end

    def create_mr_delivery_item_batch(attrs)
      item_batch_id = create(:mr_delivery_item_batches, attrs)
      ensure_item_quantities(attrs[:mr_delivery_item_id])
      item_batch_id
    end

    def update_mr_delivery_item_batch(id, attrs)
      update(:mr_delivery_item_batches, id, attrs)
      ensure_item_quantities(attrs[:mr_delivery_item_id])
    end

    def ensure_item_quantities(mr_delivery_item_id)
      sum = DB[:mr_delivery_item_batches].where(mr_delivery_item_id: mr_delivery_item_id).sum(:quantity_received)
      DB[:mr_delivery_items].where(id: mr_delivery_item_id).update(quantity_received: sum, quantity_on_note: sum)
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

    def create_mr_delivery(attrs) # rubocop:disable Metrics/AbcSize
      hash     = attrs.to_h
      po_id    = hash.delete(:mr_purchase_order_id)
      del_id   = create(:mr_deliveries, hash)
      po_items = DB[:mr_purchase_order_items].where(mr_purchase_order_id: po_id).all
      consignment = DB[:mr_purchase_orders].where(id: po_id).get(:is_consignment_stock)
      po_items.each do |item|
        item_id = DB[:mr_delivery_items].insert(
          mr_delivery_id: del_id,
          mr_purchase_order_item_id: item[:id],
          mr_product_variant_id: item[:mr_product_variant_id],
          invoiced_unit_price: item[:unit_price]
        )
        DB[:mr_delivery_item_batches].insert(mr_delivery_item_id: item_id, client_batch_number: 'Consignment Stock') if consignment
      end
      del_id
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
      info = nil
      info = sku_info_from_batch_id(mr_delivery_item_batch_id) if mr_delivery_item_batch_id
      info = sku_info_from_item_id(mr_delivery_item_id) if mr_delivery_item_id
      info = sku_info_from_sku_id(sku_id) if sku_id
      info
    end

    def sku_info_from_batch_id(mr_delivery_item_batch_id) # rubocop:disable Metrics/AbcSize
      batch = DB[:mr_delivery_item_batches].where(id: mr_delivery_item_batch_id)
      batch_number = batch.get(:client_batch_number)

      item_id = batch.get(:mr_delivery_item_id)
      item = DB[:mr_delivery_items].where(id: item_id)

      pv                 = DB[:material_resource_product_variants].where(id: item.get(:mr_product_variant_id))
      pv_code, pv_number = pv.get(%i[product_variant_code product_variant_number])
      pv_number          = ConfigRepo.new.format_product_variant_number(pv_number)
      sku                = DB[:mr_skus].where(mr_delivery_item_batch_id: mr_delivery_item_batch_id,
                                              mr_product_variant_id: item.get(:mr_product_variant_id))
      sku_number         = sku.get(:sku_number)
      delivery_number    = DB[:mr_deliveries].where(id: item.get(:mr_delivery_id)).get(:delivery_number)
      no_of_prints       = batch.get(:quantity_received) - batch.get(:quantity_putaway)
      no_of_prints       = 1 if no_of_prints.zero? || no_of_prints.negative?
      {
        sku_number: sku_number,
        product_variant_code: pv_code,
        product_variant_number: pv_number,
        batch_number: batch_number,
        no_of_prints: no_of_prints,
        delivery_number: delivery_number
      }
    end

    def sku_info_from_item_id(mr_delivery_item_id) # rubocop:disable Metrics/AbcSize
      item = DB[:mr_delivery_items].where(id: mr_delivery_item_id)

      pv = DB[:material_resource_product_variants].where(id: item.get(:mr_product_variant_id))
      # pv_code = pv.get(:product_variant_code)
      pv_code, pv_number = pv.get(%i[product_variant_code product_variant_number])
      pv_number          = ConfigRepo.new.format_product_variant_number(pv_number)
      batch_number       = DB[:mr_internal_batch_numbers].where(id: pv.get(:mr_internal_batch_number_id)).get(:batch_number)

      sku = DB[:mr_skus].where(mr_internal_batch_number_id: pv.get(:mr_internal_batch_number_id),
                               mr_product_variant_id: item.get(:mr_product_variant_id))
      sku_number = sku.get(:sku_number)
      delivery_number = DB[:mr_deliveries].where(id: item.get(:mr_delivery_id)).get(:delivery_number)
      no_of_prints = item.get(:quantity_received) - item.get(:quantity_putaway)
      no_of_prints = 1 if no_of_prints.zero? || no_of_prints.negative?
      {
        sku_number: sku_number,
        product_variant_code: pv_code,
        product_variant_number: pv_number,
        batch_number: batch_number,
        no_of_prints: no_of_prints,
        delivery_number: delivery_number
      }
    end

    def sku_info_from_sku_id(sku_id) # rubocop:disable Metrics/AbcSize
      sku             = DB[:mr_skus].where(id: sku_id).first
      no_of_prints    = 0
      delivery_number = 'unknown'
      if (item_batch_id = sku[:mr_delivery_item_batch_id])
        batch = DB[:mr_delivery_item_batches].where(id: item_batch_id)
        item = DB[:mr_delivery_items].where(id: batch.get(:mr_delivery_item_id))
        delivery_number = DB[:mr_deliveries].where(id: item.get(:mr_delivery_id)).get(:delivery_number)
        batch_number = DB[:mr_delivery_item_batches].where(id: item_batch_id).get(:client_batch_number)
        no_of_prints = batch.get(:quantity_received) - batch.get(:quantity_putaway)
      else
        batch_number = DB[:mr_internal_batch_numbers].where(id: sku[:mr_internal_batch_number_id]).get(:batch_number)
      end
      # pv_code = DB[:material_resource_product_variants].where(id: sku[:mr_product_variant_id]).get(:product_variant_code)
      pv_code, pv_number = DB[:material_resource_product_variants].where(id: sku[:mr_product_variant_id]).get(%i[product_variant_code product_variant_number])
      pv_number          = ConfigRepo.new.format_product_variant_number(pv_number)
      sku_number         = sku[:sku_number]
      no_of_prints       = 1 if no_of_prints.zero? || no_of_prints.negative?
      {
        sku_number: sku_number,
        product_variant_code: pv_code,
        product_variant_number: pv_number,
        batch_number: batch_number,
        no_of_prints: no_of_prints,
        delivery_number: delivery_number
      }
    end

    def resolve_location_id_from_scan(val, scan_field)
      if ['', 'location_short_code'].include?(scan_field)
        location_id_from_location_short_code(val)
      else
        val
      end
    end

    def location_id_from_location_short_code(value)
      DB[:locations].where(location_short_code: value).get(:id)
    end

    def location_id_from_sku_location_id(sku_location_id)
      DB[:mr_sku_locations].where(id: sku_location_id).get(:location_id)
    end

    def location_long_code_from_location_id(location_id)
      DB[:locations].where(id: location_id).get(:location_long_code)
    end

    def location_can_store_stock?(location_id)
      DB[:locations].where(id: location_id).get(:can_store_stock)
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

    def update_delivery_putaway_quantity(sku_id, quantity, delivery_id) # rubocop:disable Metrics/AbcSize
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

    def update_delivery_putaway_statuses(delivery_id) # rubocop:disable Metrics/AbcSize
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

    def update_purchase_order_statuses(po_item_id) # rubocop:disable Metrics/AbcSize
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

    def html_delivery_progress_report(delivery_id, sku_id, to_location_id) # rubocop:disable Metrics/AbcSize
      return nil unless delivery_id && sku_id && to_location_id

      total_items = DB[:mr_delivery_items].where(mr_delivery_id: delivery_id).all
      done = total_items.select { |r| r[:quantity_putaway].to_f >= r[:quantity_received].to_f }.count
      sku = DB[:mr_skus].where(id: sku_id).first
      product_variant_code = DB[:material_resource_product_variants].where(id: sku[:mr_product_variant_id]).get(:product_variant_code)
      item = DB[:mr_delivery_items].where(mr_product_variant_id: sku[:mr_product_variant_id], mr_delivery_id: delivery_id)
      <<~HTML
        Delivery (#{delivery_number_from_id(delivery_id)}): #{done} of #{total_items.count} line-items completed.<br>
        Last scan:<br>
        LOC: #{location_long_code_from_location_id(to_location_id)}<br>
        SKU (#{sku_number_from_id(sku_id)}): #{product_variant_code}<br>
        #{item.get(:quantity_putaway).to_i} of #{item.get(:quantity_received).to_i} stock items putaway.<br>
      HTML
    end

    def inline_update_delivery_item(id, attrs)
      val = attrs[:column_value].empty? ? nil : attrs[:column_value]
      update(:mr_delivery_items, id, invoiced_unit_price: val)
    end

    def del_sub_totals(id, opts = {})
      subtotal = del_total_items(id)
      costs = del_total_costs(id)
      vat = del_total_vat(id, subtotal + costs)
      {
        subtotal: UtilityFunctions.delimited_number(subtotal, opts),
        costs: UtilityFunctions.delimited_number(costs, opts),
        vat: UtilityFunctions.delimited_number(vat, opts),
        total: UtilityFunctions.delimited_number(subtotal + costs + vat, opts)
      }
    end

    def del_total_items(id)
      DB['SELECT SUM(quantity_received * invoiced_unit_price) AS total FROM mr_delivery_items WHERE mr_delivery_id = ?', id].single_value || AppConst::BIG_ZERO
    end

    def del_total_vat(id, subtotal)
      return AppConst::BIG_ZERO if subtotal.zero?

      # We take the first Purchase Order we can find for the VAT factor
      po_item_id = DB[:mr_delivery_items].where(mr_delivery_id: id).get(:mr_purchase_order_item_id)
      po_id = DB[:mr_purchase_order_items].where(id: po_item_id).get(:mr_purchase_order_id)
      factor = po_vat_factor(po_id)
      subtotal * factor
    end

    def del_total_costs(id)
      DB[:mr_purchase_invoice_costs].where(mr_delivery_id: id).sum(:amount) || AppConst::BIG_ZERO
    end

    def update_current_prices(delivery_id)
      items = DB[:mr_delivery_items].where(mr_delivery_id: delivery_id)
                                    .map { |r| { pv_id: r[:mr_product_variant_id], price: r[:invoiced_unit_price] } }
      items.each do |item|
        update_mr_product_variant_current_prices(item)
      end
    end

    def update_mr_product_variant_current_prices(item)
      product = config_repo.find_matres_product_variant(item[:pv_id])
      stock_adj_price = product.stock_adj_price.positive? ? product.stock_adj_price : item[:price]
      update(:material_resource_product_variants, item[:pv_id], current_price: item[:price], stock_adj_price: stock_adj_price)
    end

    def config_repo
      ConfigRepo.new
    end

    def ref_no_already_exists?(ref_no)
      exists?(:mr_inventory_transactions, ref_no: ref_no)
    end

    def over_under_supply(quantity_received, purchase_order_item_id)
      po_item              = DB[:mr_purchase_order_items].where(id: purchase_order_item_id).first
      qty_required         = po_item[:quantity_required] || AppConst::BIG_ZERO
      delivered_quantities = total_delivered_quantities(po_item[:id])

      total_received = delivered_quantities + BigDecimal(quantity_received)
      total_received - qty_required
    end

    def total_delivered_quantities(purchase_order_item_id)
      qty_received = DB[:mr_delivery_items].join(:mr_deliveries, id: :mr_delivery_id)
                                           .where(mr_purchase_order_item_id: purchase_order_item_id, verified: true)
                                           .sum(:quantity_received)
      BigDecimal(qty_received || '0')
    end

    def update_mr_delivery_item(id, attrs)
      new_attrs = attrs.to_h
      new_attrs.delete(:quantity_over_under_supplied)
      update(:mr_delivery_items, id, new_attrs)
    end

    def create_mr_delivery_item(attrs)
      new_attrs = attrs.to_h
      new_attrs.delete(:quantity_over_under_supplied)

      consignment = DB[:mr_purchase_orders].where(
        id: DB[:mr_purchase_order_items].where(
          id: attrs[:mr_purchase_order_item_id]
        ).get(:mr_purchase_order_id)
      ).get(:is_consignment_stock)
      item_id = create(:mr_delivery_items, new_attrs)
      DB[:mr_delivery_item_batches].insert(mr_delivery_item_id: item_id, client_batch_number: 'Consignment Stock') if consignment
      item_id
    end

    # @param [Hash] attrs => quantity_received, quantity_on_note, mr_purchase_order_item_id
    def prepare_delivery_item_quantities(attrs)
      new_attrs = add_over_under_supply_values(attrs.to_h)
      calculate_for_qty_difference(new_attrs)
    end

    # @param [Hash] attrs
    # Should only be updated if the delivery has not yet been verified
    def add_over_under_supply_values(attrs)
      amt = over_under_supply(attrs[:quantity_received], attrs[:mr_purchase_order_item_id])

      attrs[:quantity_over_under_supplied] = amt
      attrs[:quantity_over_supplied] = amt.positive? ? amt : AppConst::BIG_ZERO
      attrs[:quantity_under_supplied] = amt.negative? ? amt.abs : AppConst::BIG_ZERO
      attrs
    end

    def calculate_for_qty_difference(attrs)
      attrs[:quantity_difference] = attrs[:quantity_on_note] - attrs[:quantity_received] - attrs[:quantity_returned]
      attrs
    end

    def delivery_stock(sku_id, from_loc_id) # rubocop:disable Metrics/AbcSize
      location_type_id = DB[:location_types].where(location_type_code: AppConst::LOCATION_TYPES_RECEIVING_BAY).get(:id)
      rec_bay = DB[:locations].where(id: from_loc_id, location_type_id: location_type_id, can_store_stock: true).first
      return nil unless rec_bay

      sku = DB[:mr_skus].where(id: sku_id)
      del_id = if (batch_id = sku.get(:mr_delivery_item_batch_id))
                 batch = DB[:mr_delivery_item_batches].where(id: batch_id, putaway_completed: false)
                 DB[:mr_delivery_items].where(id: batch.get(:mr_delivery_item_id)).get(:mr_delivery_id)
               else
                 item = DB[:mr_delivery_items].where(
                   mr_product_variant_id: sku.get(:mr_product_variant_id),
                   putaway_completed: false
                 )
                 item.get(:mr_delivery_id)
               end
      del_id ? DB[:mr_deliveries].where(id: del_id).get(:delivery_number) : nil
    end

    def deliveries_for_purchase_order_check(purchase_order_id)
      item_ids = mr_purchase_order_items(purchase_order_id)
      DB[:mr_delivery_items].where(mr_purchase_order_item_id: item_ids).any?
    end
  end
end
