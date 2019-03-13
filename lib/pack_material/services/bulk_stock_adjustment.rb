# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize

module PackMaterialApp
  class BulkStockAdjustment < BaseService
    # @param [Integer] bulk_stock_adjustment_id
    # @param [Integer] business_process_id
    # @param [Hash] opts { :user_name, :parent_transaction_id }
    def initialize(bulk_stock_adjustment_id, business_process_id = nil, opts = {})
      @repo = MrStockRepo.new
      @transaction_repo = PackMaterialApp::TransactionsRepo.new
      @bulk_stock_adjustment_id = bulk_stock_adjustment_id
      @business_process_id = business_process_id || business_process
      @opts = opts
    end

    def call
      bulk_stock_adj = @repo.find_hash(:mr_bulk_stock_adjustments, @bulk_stock_adjustment_id)
      return failed_response('Bulk Stock Adjustment record does not exist') unless bulk_stock_adj

      @ref_no = bulk_stock_adj[:ref_no]

      destroy_stock_items = create_stock_items = []
      items = DB[:bulk_stock_adjustment_items].where(mr_bulk_stock_adjustment_id: @bulk_stock_adjustment_id).all
      items.each do |item|
        if item[:system_quantity] > item[:actual_quantity]
          destroy_stock_items << item
        else
          create_stock_items << item
        end
      end

      destroy_stock_items.each do |item|
        qty = item[:system_quantity] - item[:actual_quantity]
        res = RemoveMrStock.call(item[:mr_sku_id],
                                 item[:location_id],
                                 qty,
                                 ref_no: @ref_no,
                                 parent_transaction_id: destroy_transaction_id,
                                 business_process_id: @business_process_id,
                                 user_name: @opts[:user_name])
        return failed_response("Bulk Stock Adjustment Item #{item[:id]}: Attempt to destroy stock failed - #{res.message}") unless res.success
        DB[:bulk_stock_adjustment_items].where(id: item[:id]).update(mr_inventory_transaction_item_id: res.instance)
      end

      create_stock_items.each do |item|
        qty = item[:actual_quantity] - item[:system_quantity]
        res = CreateMrStock.call([item[:mr_sku_id]],
                                 @business_process_id,
                                 to_location_id: item[:location_id],
                                 user_name: @opts[:user_name],
                                 ref_no: @ref_no,
                                 parent_transaction_id: create_transaction_id,
                                 quantities: [{ sku_id: item[:mr_sku_id], qty: qty }])
        return failed_response("Bulk Stock Adjustment Item #{item[:id]}: Attempt to create stock failed - #{res.message}") unless res.success
        transaction_item_id = res.instance[:transaction_item_ids][0][:transaction_item_id]
        DB[:bulk_stock_adjustment_items].where(id: item[:id]).update(mr_inventory_transaction_item_id: transaction_item_id)
      end

      bulk_stock_adj = DB[:mr_bulk_stock_adjustments].where(id: @bulk_stock_adjustment_id)
      bulk_stock_adj.update(create_transaction_id: create_transaction_id) if create_stock_items.any?
      bulk_stock_adj.update(destroy_transaction_id: destroy_transaction_id) if destroy_stock_items.any?

      success_response('ok')
    end

    def business_process
      DB[:business_processes].where(process: 'BULK STOCK ADJUSTMENT').get(:id)
    end

    def destroy_transaction_id
      transaction_id('destroy')
    end

    def create_transaction_id
      transaction_id('create')
    end

    def transaction_id(type)
      type_id = @repo.transaction_type_id_for(type)
      @transaction_repo.create_mr_inventory_transaction(
        business_process_id: @business_process_id,
        ref_no: @ref_no,
        active: true,
        created_by: @opts[:user_name],
        mr_inventory_transaction_type_id: type_id
      )
    end
  end
end