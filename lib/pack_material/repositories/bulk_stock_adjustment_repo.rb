# frozen_string_literal: true

module PackMaterialApp
  class BulkStockAdjustmentRepo < BaseRepo
    def system_quantity(mr_sku_id, location_id)
      transaction_repo.system_quantity(mr_sku_id: mr_sku_id, location_id: location_id)
    end

    def find_business_process_id
      DB[:business_processes].where(process: AppConst::PROCESS_BULK_STOCK_ADJUSTMENTS).get(:id)
    end

    def update_item_transaction_id(item_id, transaction_id)
      update(:mr_bulk_stock_adjustment_items, item_id, mr_inventory_transaction_item_id: transaction_id)
    end

    def update_transaction_ids(id, create_id, destroy_id)
      update(:mr_bulk_stock_adjustments, id,
             create_transaction_id: create_id,
             destroy_transaction_id: destroy_id)
    end

    def transaction_id(type, attrs)
      type_id = mr_stock_repo.transaction_type_id_for(type)
      transaction_repo.create_mr_inventory_transaction(
        business_process_id: attrs[:business_process_id],
        ref_no: attrs[:ref_no],
        active: true,
        created_by: attrs[:user_name],
        mr_inventory_transaction_type_id: type_id
      )
    end

    def separate_items(bulk_stock_adjustment_id)
      destroy_stock_items = []
      create_stock_items = []
      items = all_hash(:mr_bulk_stock_adjustment_items, mr_bulk_stock_adjustment_id: bulk_stock_adjustment_id)
      items.each do |item|
        sys_qty = system_quantity(item[:mr_sku_id], item[:location_id])
        if sys_qty > item[:actual_quantity].to_d
          destroy_stock_items << item
        else
          create_stock_items << item
        end
      end
      {
        destroy_stock_items: destroy_stock_items,
        create_stock_items: create_stock_items
      }
    end

    def mr_stock_repo
      PackMaterialApp::MrStockRepo.new
    end

    def transaction_repo
      PackMaterialApp::TransactionsRepo.new
    end
  end
end
