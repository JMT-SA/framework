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

    build_for_select :mr_internal_batch_numbers,
                     label: :batch_number,
                     value: :id,
                     no_active_check: true,
                     order_by: :batch_number

    crud_calls_for :mr_internal_batch_numbers, name: :mr_internal_batch_number, wrapper: MrInternalBatchNumber

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
    def for_select_purchase_orders_with_supplier
      DB[:mr_purchase_orders].where(
        approved: true
      ).select(
        :id,
        :purchase_order_number,
        Sequel.function(:fn_party_role_name, :supplier_party_role_id)
      ).map { |r| [[r[:purchase_order_number], r[:fn_party_role_name]].join(' - from: '), r[:id]] }
    end

    # @return [Array] returns for select with association label name
    def for_select_mr_purchase_order_items(purchase_order_id)
      for_select_raw_mr_purchase_order_items(
        where: { mr_purchase_order_id: purchase_order_id }
      ).map { |r| [DB[:material_resource_product_variants].where(id: r[0]).select(:product_variant_code).single_value, r[1]] }
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
      ).select(:mr_purchase_order_id).single_value
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

    # Purchase Order States/Statuses

    # If Purchase Order has_items && is not approved
    #
    # @return [Bool]
    def can_approve_purchase_order?(purchase_order_id)
      po = find_with_association(:mr_purchase_orders, purchase_order_id,
                                 sub_tables: [{ sub_table: :mr_purchase_order_items }])
      po && po[:mr_purchase_order_items].any? && (po[:purchase_order_number].nil? || !po[:approved])
    end

    # def can_reopen_purchase_order?(purchase_order_id)
    #   approved = find_hash(:mr_purchase_orders, purchase_order_id)[:approved]
    #   receiving_deliveries = DB['SELECT']
    #   approved && !receiving_deliveries
    #   # approved && not currently receiving deliveries
    # end

    def approve_purchase_order!(purchase_order_id)
      po = find_hash(:mr_purchase_orders, purchase_order_id)
      log_status('mr_purchase_orders', purchase_order_id, 'APPROVED')
      update(:mr_purchase_orders, purchase_order_id, approved: true)
      update_with_document_number('doc_seqs_po_number', purchase_order_id) unless po[:purchase_order_number]
    end

    def find_mr_delivery(id)
      find_with_association(:mr_deliveries, id,
                            lookup_functions: [{ function: :fn_party_role_name,
                                                 args: [:transporter_party_role_id],
                                                 col_name: :transporter }],
                            wrapper: MrDelivery)
    end

    def find_mr_delivery_item_batch(id)
      hash = find_with_association(:mr_delivery_item_batches, id,
                                   parent_tables: [{
                                     parent_table: :mr_internal_batch_numbers,
                                     flatten_columns: { batch_number: :internal_batch_number }
                                   }])
      hash[:batch_number] = hash[:client_batch_number] || hash[:internal_batch_number]
      MrDeliveryItemBatch.new(hash)
    end

    def verify_mr_delivery(id)
      update(:mr_deliveries, id, verified: true)
    end

    def mr_delivery_items(mr_delivery_id)
      DB[:mr_delivery_items].where(mr_delivery_id: mr_delivery_id).select_map(:id)
    end

    def delivery_has_items_without_batches(mr_delivery_id)
      DB['SELECT id FROM mr_delivery_items WHERE NOT EXISTS(
            SELECT id FROM mr_delivery_item_batches WHERE mr_delivery_item_id = mr_delivery_items.id
      ) AND mr_delivery_items.mr_delivery_id = ?', mr_delivery_id].all
    end

    def delivery_item_batches(mr_delivery_item_id)
      where(:mr_delivery_item_batches, MrDeliveryItemBatch, mr_delivery_item_id: mr_delivery_item_id)
    end

    def delivery_items_fulfilled(mr_delivery_id)
      item_quantities(mr_delivery_id) == batch_quantities(mr_delivery_id)
    end

    def item_quantities(mr_delivery_id)
      DB[:mr_delivery_items].where(mr_delivery_id: mr_delivery_id).select_map(:quantity_received).sum
    end

    def batch_quantities(mr_delivery_id)
      item_ids = DB[:mr_delivery_items].where(mr_delivery_id: mr_delivery_id).select_map(:id)
      DB[:mr_delivery_item_batches].where(mr_delivery_item_id: item_ids).select_map(:quantity_received).sum
    end

    def delete_mr_delivery_item(mr_delivery_item_id)
      DB[:mr_delivery_item_batches].where(mr_delivery_item_id: mr_delivery_item_id).delete
      delete(:mr_delivery_items, mr_delivery_item_id)
    end

    def find_or_create_sku_location_ids(sku_ids, to_location_id)
      result = []
      sku_ids.each do |sku_id|
        sku_location_id = DB[:mr_sku_locations].where(location_id: to_location_id, mr_sku_id: sku_id).select(:id).single_value
        sku_location_id ||= create(:mr_sku_locations, location_id: to_location_id, mr_sku_id: sku_id)

        find_hash(:mr_skus, sku_id)
        DB[:mr_sku_locations].update(:quantity, Sequel.function(sum, :quantity))

        result << { sku_id: sku_id, sku_location_id: sku_location_id }
      end
      result
    end

    def sku_for_barcode(id)
      query = <<~SQL
        SELECT sku_number, pv.product_variant_code, db.quantity_received AS no_of_prints, batch_number
        FROM public.mr_skus
        join material_resource_product_variants pv ON pv.id = mr_product_variant_id
        JOIN mr_delivery_item_batches db ON db.id = mr_skus.mr_delivery_item_batch_id
        WHERE mr_skus.mr_delivery_item_batch_id = ?
      SQL
      DB[query, id].first
    end
  end
end
