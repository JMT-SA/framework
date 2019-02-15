# frozen_string_literal: true

module PackMaterialApp
  class TransactionsRepo < BaseRepo
    build_for_select :mr_inventory_transactions,
                     label: :created_by,
                     value: :id,
                     no_active_check: true,
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

    def sku_number_for_sku_location(sku_location_id)
      DB[:mr_skus].where(id: DB[:mr_sku_locations].where(id: sku_location_id).get(:mr_sku_id)).get(:sku_number)
    end

    def allowed_locations
      ancestor_id = DB[:locations].where(location_code: 'PM').get(:id)
      descendant_ids = location_repo.descendants_for_ancestor_id(ancestor_id) - [ancestor_id]

      type_id = DB[:location_storage_types].where(storage_type_code: PackMaterialApp::DOMAIN_NAME).get(:id)
      DB[:locations].where(primary_storage_type_id: type_id, id: descendant_ids).map { |r| [r[:location_code], r[:id]] }
    end

    def location_repo
      MasterfilesApp::LocationRepo.new
    end
  end
end
