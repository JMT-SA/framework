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
             mr_inventory_transaction_id: transaction_id,
             is_stock_take: attrs[:is_stock_take])
    end

    def create_mr_bulk_stock_adjustment_item(attrs)
      sku_location_id = DB[:mr_sku_locations].where(mr_sku_id: attrs[:mr_sku_id], location_id: attrs[:location_id]).get(:id)
      sku_location_id ||= create(:mr_sku_locations, mr_sku_id: attrs[:mr_sku_id], location_id: attrs[:location_id], quantity: 0)

      hash = { sku_location_id: sku_location_id }
      hash[:mr_bulk_stock_adjustment_id] = attrs[:mr_bulk_stock_adjustment_id]

      sku_location = DB[:mr_sku_locations].where(id: sku_location_id)
      sku_id = sku_location.get(:mr_sku_id)
      location_id = sku_location.get(:location_id)

      mr_product_variant_id = DB[:mr_skus].where(id: sku_id).get(:mr_product_variant_id)
      variant = DB[:material_resource_product_variants].where(id: mr_product_variant_id)
      product_variant_number = variant.get(:product_variant_number)
      product_variant_code = variant.get(:product_variant_code)
      sub_type_id = variant.get(:sub_type_id)

      sub_type = DB[:material_resource_sub_types].where(id: sub_type_id)
      mr_sub_type_name = sub_type.get(:sub_type_name)
      mr_type_id = sub_type.get(:material_resource_type_id)
      mr_type_name = DB[:material_resource_types].where(id: mr_type_id).get(:type_name)
      # inventory_uom_code

      create(:mr_bulk_stock_adjustment_items,
             mr_bulk_stock_adjustment_id: attrs[:mr_bulk_stock_adjustment_id],
             mr_sku_location_id: sku_location_id,
             sku_number: DB[:mr_skus].where(id: sku_id).get(:sku_number),
             mr_sku_id: sku_id,
             location_id: location_id,
             product_variant_number: product_variant_number,
             # product_number: ,
             mr_type_name: mr_type_name,
             mr_sub_type_name: mr_sub_type_name,
             product_variant_code: product_variant_code,
             # product_code: ,
             # inventory_uom_code: ,
             location_long_code: DB[:locations].where(id: location_id).get(:location_long_code))
    end

    def get_sku_location_info_ids(sku_location_id)
      sku_location = DB[:mr_sku_locations].where(id: sku_location_id)
      {
        sku_id: sku_location.get(:mr_sku_id),
        location_id: sku_location.get(:location_id)
      }
    end

    def bulk_stock_adjustment_sku_numbers(bulk_stock_adjustment_id)
      DB[:mr_skus].where(
        id: bulk_stock_adjustment_sku_ids(bulk_stock_adjustment_id)
      ).map { |r| [r[:sku_number], r[:id]] }
    end

    def bulk_stock_adjustment_locations(bulk_stock_adjustment_id)
      DB[:locations].where(
        id: bulk_stock_adjustment_location_ids(bulk_stock_adjustment_id)
      ).map { |r| [r[:location_long_code], r[:id]] }
    end

    def bulk_stock_adjustment_location_ids(bulk_stock_adjustment_id)
      DB[:mr_bulk_stock_adjustments_locations].where(
        mr_bulk_stock_adjustment_id: bulk_stock_adjustment_id
      ).select_map(:location_id)
    end

    def bulk_stock_adjustment_sku_ids(bulk_stock_adjustment_id)
      DB[:mr_bulk_stock_adjustments_sku_numbers].where(
        mr_bulk_stock_adjustment_id: bulk_stock_adjustment_id
      ).select_map(:mr_sku_id)
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
      ancestor_id = DB[:locations].where(location_long_code: 'PM').get(:id)
      descendant_ids = location_repo.descendants_for_ancestor_id(ancestor_id) - [ancestor_id]

      type_id = DB[:location_storage_types].where(storage_type_code: PackMaterialApp::DOMAIN_NAME).get(:id)
      DB[:locations].where(primary_storage_type_id: type_id, id: descendant_ids).map { |r| [r[:location_long_code], r[:id]] }
    end

    def location_repo
      MasterfilesApp::LocationRepo.new
    end
  end
end
