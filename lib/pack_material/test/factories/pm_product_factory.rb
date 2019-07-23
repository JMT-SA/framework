# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength
# rubocop:disable Metrics/AbcSize

module PackMaterialApp
  module PmProductFactory
    # uses ConfigFactory

    def create_pack_material_product_variant
      product = create_product
      default = {
        pack_material_product_id: product[:id],
        reference_size: 'size',
        reference_dimension: 'dim',
        reference_quantity: 'qty'
      }
      id = DB[:pack_material_product_variants].insert(default)
      DB[:pack_material_product_variants].where(id: id).first
    end

    def create_material_resource_product_variant(opts = {})
      variant = create_pack_material_product_variant
      sub_type_id = DB[:pack_material_products].where(id: variant[:pack_material_product_id]).first[:material_resource_sub_type_id]
      default = {
        sub_type_id: sub_type_id,
        product_variant_id: variant[:id],
        product_variant_table_name: 'pack_material_product_variants',
        product_variant_number: variant[:product_variant_number],
        product_variant_code: variant[:product_variant_code]
      }
      {
        id: DB[:material_resource_product_variants].insert(default.merge(opts)),
        product_variant_id: variant[:id]
      }
    end

    def create_matres_product_variant_party_role(type = AppConst::ROLE_SUPPLIER, opts = {})
      variant = create_material_resource_product_variant
      supplier = create_supplier
      customer = create_customer
      supplier_type = type == AppConst::ROLE_SUPPLIER
      supplier_id = supplier_type ? supplier[:id] : nil
      customer_id = supplier_type ? nil : customer[:id]
      default = {
        supplier_id: supplier_id,
        customer_id: customer_id,
        material_resource_product_variant_id: variant[:id],
        supplier_lead_time: 12
      }
      role_link_id = DB[:material_resource_product_variant_party_roles].insert(default.merge(opts))
      {
        id: role_link_id,
        supplier_id: supplier_id,
        customer_id: customer_id
      }
    end

    def create_mr_delivery(opts = {})
      default = {
        driver_name: 'Jack',
        vehicle_registration: 123,
        client_delivery_ref_number: 12,
        receipt_location_id: @fixed_table_set[:locations][:default_id]
      }
      del_id = DB[:mr_deliveries].insert(default.merge(opts))
      {
        id: del_id
      }
    end

    def create_mr_internal_batch_number(opts = {})
      default = {
        batch_number: rand(1_000_000_000),
        description: 'desc'
      }
      batch_id = DB[:mr_internal_batch_numbers].insert(default.merge(opts))
      {
        id: batch_id
      }
    end

    def create_mr_sku(opts = {})
      variant = create_material_resource_product_variant[:id]
      party_role_id = create_party_role[:id]
      batch_id = create_mr_internal_batch_number[:id]
      skus = DB[:mr_skus].order_by(:id).all
      sku_number = skus.any? ? (skus.last[:id] + 1) : 1

      default = {
        mr_product_variant_id: variant,
        owner_party_role_id: party_role_id,
        sku_number: sku_number,
        mr_internal_batch_number_id: batch_id
      }
      sku_id = DB[:mr_skus].insert(default.merge(opts))
      {
        id: sku_id
      }
    end

    def create_pack_material_location(opts = {})
      default = {
        primary_assignment_id: @fixed_table_set[:locations][:assignment_id],
        primary_storage_type_id: @fixed_table_set[:locations][:storage_type_id],
        location_type_id: @fixed_table_set[:locations][:type_id],
        location_description: 'Default Location',
        location_long_code: 'DEFAULT',
        location_short_code: 'DEF'
      }
      # Build tree here
      location_id = DB[:locations].insert(default.merge(opts))
      {
        id: location_id
      }
    end

    def create_transaction(opts = {})
      type_id = @fixed_table_set[:inventory_transaction_types][:create_stock_id]
      default = {
        business_process_id: @fixed_table_set[:processes][:bulk_stock_adjustments_process_id],
        ref_no: "ref_no#{rand(1_000_000)}",
        active: true,
        created_by: 'user_name',
        mr_inventory_transaction_type_id: type_id
      }
      id = DB[:mr_inventory_transactions].insert(default.merge(opts))
      {
        id: id
      }
    end

    def create_transaction_item(opts = {})
      transaction_id = create_transaction[:id]
      location_id = @fixed_table_set[:locations][:default_id]
      sku_id = create_mr_sku[:id]
      default = {
        mr_inventory_transaction_id: transaction_id,
        from_location_id: location_id,
        mr_sku_id: sku_id,
        inventory_uom_id: @fixed_table_set[:uoms][:uom_id],
        quantity: 40
      }
      attrs = default.merge(opts)
      item_id = DB[:mr_inventory_transaction_items].insert(attrs)
      {
        id: item_id,
        parent_id: attrs[:mr_inventory_transaction_id],
        location_id: attrs[:from_location_id],
        sku_id: attrs[:mr_sku_id]
      }
    end

    def create_bulk_stock_adjustment(opts = {})
      default = {
        stock_adjustment_number: 1,
        active: true,
        is_stock_take: false,
        business_process_id: @fixed_table_set[:processes][:bulk_stock_adjustments_process_id],
        ref_no: 'ref_no'
      }
      attrs = default.merge(opts)
      bulk_stock_adjustment_id = DB[:mr_bulk_stock_adjustments].insert(attrs)
      {
        id: bulk_stock_adjustment_id
      }
    end

    def create_bulk_stock_adjustment_item(opts = {})
      bsa_id = opts[:mr_bulk_stock_adjustment_id] || create_bulk_stock_adjustment[:id]
      location_id = @fixed_table_set[:locations][:default_id]
      sku_id = create_mr_sku[:id]
      inventory_uom_id = @fixed_table_set[:uoms][:uom_id]
      default = {
        mr_bulk_stock_adjustment_id: bsa_id,
        mr_inventory_transaction_item_id: nil,
        mr_sku_id: sku_id,
        location_id: location_id,
        sku_number: 1,
        product_variant_number: '100105001007',
        mr_type_name: 'Testa',
        mr_sub_type_name: 'Marketers Suppliers',
        product_variant_code: 'TS_MS_1_Mar Sup-007',
        location_long_code: 'PM_B5_MV1',
        inventory_uom_code: 'each',
        scan_to_location_long_code: nil,
        system_quantity: 0.0,
        actual_quantity: 50.0,
        stock_take_complete: false,
        active: true,
        inventory_uom_id: inventory_uom_id
      }
      attrs = default.merge(opts)
      item_id = DB[:mr_bulk_stock_adjustment_items].insert(attrs)
      {
        id: item_id,
        parent_id: attrs[:mr_bulk_stock_adjustment_id]
      }
    end
  end
end
# rubocop:enable Metrics/ModuleLength
# rubocop:enable Metrics/AbcSize
