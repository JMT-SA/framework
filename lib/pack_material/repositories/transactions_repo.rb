# frozen_string_literal: true

module PackMaterialApp
  class TransactionsRepo < BaseRepo
    build_for_select :mr_inventory_transactions,
                     label: :created_by,
                     value: :id,
                     order_by: :created_by

    crud_calls_for :mr_inventory_transactions, name: :mr_inventory_transaction, wrapper: MrInventoryTransaction

    build_for_select :mr_inventory_transaction_types,
                     label: :type_name,
                     value: :id,
                     no_active_check: true,
                     order_by: :type_name

    crud_calls_for :mr_inventory_transaction_types, name: :mr_inventory_transaction_type, wrapper: MrInventoryTransactionType

    build_for_select :mr_inventory_transaction_items,
                     label: :id,
                     value: :id,
                     no_active_check: true,
                     order_by: :id

    crud_calls_for :mr_inventory_transaction_items, name: :mr_inventory_transaction_item, wrapper: MrInventoryTransactionItem

    build_for_select :mr_skus,
                     label: :sku_number,
                     value: :id,
                     no_active_check: true,
                     order_by: :sku_number

    crud_calls_for :mr_skus, name: :mr_sku, wrapper: MrSku

    build_for_select :mr_sku_locations,
                     label: :id,
                     value: :id,
                     no_active_check: true,
                     order_by: :id

    crud_calls_for :mr_sku_locations, name: :mr_sku_location, wrapper: MrSkuLocation

    build_for_select :mr_bulk_stock_adjustments,
                     label: :id,
                     value: :id,
                     order_by: :id
    build_inactive_select :mr_bulk_stock_adjustments,
                          label: :id,
                          value: :id,
                          order_by: :id

    crud_calls_for :mr_bulk_stock_adjustments, name: :mr_bulk_stock_adjustment, wrapper: MrBulkStockAdjustment

    build_for_select :mr_bulk_stock_adjustment_items,
                     label: :id,
                     value: :id,
                     order_by: :id
    build_inactive_select :mr_bulk_stock_adjustment_items,
                          label: :id,
                          value: :id,
                          order_by: :id

    crud_calls_for :mr_bulk_stock_adjustment_items, name: :mr_bulk_stock_adjustment_item, wrapper: MrBulkStockAdjustmentItem

    def create_mr_bulk_stock_adjustment(attrs)
      transaction_id = create_mr_inventory_transaction(business_process_id: attrs[:business_process_id],
                                                       ref_no: attrs[:ref_no],
                                                       created_by: attrs[:user_name])
      create(:mr_bulk_stock_adjustments,
             # sku_numbers: "{#{attrs[:sku_numbers].join(',')}}",
             # location_ids: "{#{attrs[:location_ids].join(',')}}",
             mr_inventory_transaction_id: transaction_id,
             is_stock_take: attrs[:is_stock_take])
    end

    def create_mr_bulk_stock_adjustment_item(attrs)
      hsh = attrs.to_h
      # hsh[:mr_bulk_stock_adjustment_id] =
      # hsh[:actual_quantity] =
      # hsh[:stock_take_complete] =
      # hsh[:sku_number] =
      # hsh[:mr_sku_location_id] =
      # hsh[:product_variant_number] =
      # hsh[:product_number] =
      # hsh[:mr_type_name] =
      # hsh[:mr_sub_type_name] =
      # hsh[:product_variant_code] =
      # hsh[:product_code] =
      # hsh[:location_code] =
      # hsh[:inventory_uom_code] =
      # hsh[:scan_to_location_code] =
      # hsh[:system_quantity] =

      create(:mr_bulk_stock_adjustment_items,
             mr_bulk_stock_adjustment_id: attrs[:mr_bulk_stock_adjustment_id],
             mr_sku_location_id: attrs[:mr_sku_location_id],
             sku_number: attrs[:sku_number],
             product_variant_number: attrs[:product_variant_number],
             product_number: attrs[:product_number],
             mr_type_name: attrs[:mr_type_name],
             mr_sub_type_name: attrs[:mr_sub_type_name],
             product_variant_code: attrs[:product_variant_code],
             product_code: attrs[:product_code],
             location_code: attrs[:location_code],
             inventory_uom_code: attrs[:inventory_uom_code],
             scan_to_location_code: attrs[:scan_to_location_code],
             system_quantity: attrs[:system_quantity],
             actual_quantity: attrs[:actual_quantity],
             stock_take_complete: attrs[:stock_take_complete])
    end

    def link_mr_skus(bulk_stock_adjustment_id, mr_sku_ids)
      DB[:mr_bulk_stock_adjustments_sku_numbers].where(mr_bulk_stock_adjustment_id: bulk_stock_adjustment_id).delete
      mr_sku_ids.each do |mr_sku_id|
        DB[:mr_bulk_stock_adjustments_sku_numbers].insert(mr_bulk_stock_adjustment_id: bulk_stock_adjustment_id, mr_sku_id: mr_sku_id)
      end
    end

    def link_locations(bulk_stock_adjustment_id, location_ids)
      DB[:mr_bulk_stock_adjustments_locations].where(mr_bulk_stock_adjustment_id: bulk_stock_adjustment_id).delete
      location_ids.each do |location_id|
        DB[:mr_bulk_stock_adjustments_locations].insert(mr_bulk_stock_adjustment_id: bulk_stock_adjustment_id, location_id: location_id)
      end
    end

    def sku_number_for_sku_location(sku_location_id)
      DB[:mr_skus].where(id: DB[:mr_sku_locations].where(id: sku_location_id).get(:mr_sku_id)).get(:sku_number)
    end

    def allowed_locations
      ancestor_id = DB[:locations].where(location_code: 'PM').get(:id)
      descendant_ids = location_repo.descendants_for_ancestor_id(ancestor_id) - [ancestor_id]

      type_id = DB[:location_storage_types].where(storage_type_code: PackMaterialApp::DOMAIN_NAME).get(:id)
      DB[:locations].where(primary_storage_type_id: type_id, id: descendant_ids).map { |r| [r[:location_code], r[:id]] }
    end

    def location_codes_list(location_ids)
      DB[:locations].where(id: location_ids).select_map(:location_code)
    end

    def location_repo
      MasterfilesApp::LocationRepo.new
    end
  end
end
