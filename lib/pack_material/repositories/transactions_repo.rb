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
  end
end
