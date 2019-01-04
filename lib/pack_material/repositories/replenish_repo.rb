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
                                                 col_name: :transporter }],
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

    def delivery_items_fulfilled(mr_delivery_id)
      sum_of_quantity_received(mr_delivery_id) == sum_of_quantity_on_note(mr_delivery_id)
    end

    # @param [Integer] mr_delivery_id
    # @return [Numeric] sum of 'quantity received' for delivery items
    def sum_of_quantity_received(mr_delivery_id)
      DB[:mr_delivery_items].where(mr_delivery_id: mr_delivery_id).select_map(:quantity_received).sum
    end

    # @param [Integer] mr_delivery_id
    # @return [Numeric] sum of 'quantity on note' for delivery items
    def sum_of_quantity_on_note(mr_delivery_id)
      DB[:mr_delivery_items].where(mr_delivery_id: mr_delivery_id).select_map(:quantity_on_note).sum
    end

    def delete_mr_delivery_item(mr_delivery_item_id)
      DB[:mr_delivery_item_batches].where(mr_delivery_item_id: mr_delivery_item_id).delete
      delete(:mr_delivery_items, mr_delivery_item_id)
    end

    def sku_for_barcode(id)
      sku = DB[:mr_skus].where(id: id).first
      int_batch_id = sku[:mr_internal_batch_number_id]
      batch_number = int_batch_id ? DB[:mr_internal_batch_numbers].where(id: int_batch_id).get(:batch_number) : nil

      no_of_prints = nil
      if (del_batch_id = sku[:mr_delivery_item_batch_id])
        delivery_batch = DB[:mr_delivery_item_batches].where(id: del_batch_id)
        batch_number = delivery_batch.get(:client_batch_number)

        mr_delivery_id = DB[:mr_delivery_items].where(id: delivery_batch.get(:mr_delivery_item_id)).get(:mr_delivery_id)
        no_of_prints = sum_of_quantity_received(mr_delivery_id)
      end

      pv_code = DB[:material_resource_product_variants].where(
        id: sku[:mr_product_variant_id]
      ).get(:product_variant_code)
      {
        sku_number: sku[:sku_number],
        product_variant_code: pv_code,
        no_of_prints: no_of_prints,
        batch_number: batch_number
      }
    end

    def location_id_from_legacy_barcode(value)
      DB[:locations].where(legacy_barcode: value).get(:id)
    end

    def location_id_from_location_code(value)
      DB[:locations].where(location_code: value).get(:id)
    end

    def sku_ids_from_numbers(values)
      DB[:mr_skus].where(sku_number: values).map(:id)
    end
  end
end
