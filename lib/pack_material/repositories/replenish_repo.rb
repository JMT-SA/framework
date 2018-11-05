# frozen_string_literal: true

module PackMaterialApp
  class ReplenishRepo < BaseRepo
    build_for_select :mr_purchase_orders,
                     label: :purchase_account_code,
                     value: :id,
                     no_active_check: true,
                     order_by: :purchase_account_code

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

    build_for_select :mr_purchase_order_items,
                     label: :id,
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

    def find_mr_purchase_order_cost(id)
      find_with_association(:mr_purchase_order_costs, id,
                            parent_tables: [{ parent_table: :mr_cost_types, flatten_columns: { cost_code_string: :cost_type } }],
                            wrapper: MrPurchaseOrderCost)
    end

    def find_purchase_order_item(id)
      find_with_association(:mr_purchase_order_items, id,
                            parent_tables: [{ parent_table: :material_resource_product_variants, flatten_columns: { product_variant_code: :product_variant_code } },
                                            { parent_table: :uoms, flatten_columns: { uom_code: :purchasing_uom_code }, foreign_key: :purchasing_uom_id },
                                            { parent_table: :uoms, flatten_columns: { uom_code: :inventory_uom_code }, foreign_key: :inventory_uom_id }],
                            wrapper: MrPurchaseOrderItem)
    end

    def for_select_suppliers
      valid_supplier_ids = DB[:material_resource_product_variant_party_roles].distinct.select_map(:supplier_id).compact
      MasterfilesApp::PartyRepo.new.for_select_suppliers.select { |r| valid_supplier_ids.include?(r[1]) }
    end

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
    def can_approve_purchase_order?(purchase_order_id)
      po = find_with_association(:mr_purchase_orders, purchase_order_id,
                                 sub_tables: [{ sub_table: :mr_purchase_order_items }])
      no_po_number = po[:purchase_order_number].nil?
      has_items = po[:mr_purchase_order_items].any?
      has_items && (no_po_number || !po[:approved])
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
  end
end
