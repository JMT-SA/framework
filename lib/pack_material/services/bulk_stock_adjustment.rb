# frozen_string_literal: true

module PackMaterialApp
  class BulkStockAdjustmentService < BaseService
    # @param [Integer] bulk_stock_adjustment_id
    # @param [Integer] business_process_id
    # @param [Hash] opts { :user_name }
    def initialize(bulk_stock_adjustment_id, business_process_id = nil, opts = {})
      @this_repo = PackMaterialApp::BulkStockAdjustmentRepo.new
      @transaction_repo = PackMaterialApp::TransactionsRepo.new

      @bulk_stock_adjustment_id = bulk_stock_adjustment_id
      @bulk_stock_adj = @transaction_repo.find_mr_bulk_stock_adjustment(bulk_stock_adjustment_id)
      @ref_no = @bulk_stock_adj.ref_no unless @bulk_stock_adj.nil?
      @business_process_id = business_process_id || @bulk_stock_adj.business_process_id
      @opts = opts
      @destroy_transaction_id = nil
      @create_transaction_id = nil
    end

    def call
      return failed_response('Bulk Stock Adjustment record does not exist') unless @bulk_stock_adj

      res = @this_repo.apply_product_variant_prices(@bulk_stock_adjustment_id)
      return res unless res.success

      apply_stock_changes
    end

    private

    def apply_stock_changes # rubocop:disable Metrics/AbcSize
      separated_items = @this_repo.separate_items(@bulk_stock_adjustment_id)
      separated_items[:destroy_stock_items].each do |item|
        res = destroy_stock_item(item)
        return res unless res.success

        @this_repo.update_item_transaction_id(item[:id], res.instance)
      end
      separated_items[:create_stock_items].each do |item|
        res = create_stock_item(item)
        return res unless res.success

        item_transaction_id = res.instance[:transaction_item_ids][0][:transaction_item_id]
        @this_repo.update_item_transaction_id(item[:id], item_transaction_id)
      end
      # Note that @create_transaction_id and @destroy_transaction_id are only created if they should exist
      @this_repo.update_transaction_ids(@bulk_stock_adjustment_id, @create_transaction_id, @destroy_transaction_id)
      ok_response
    end

    def destroy_stock_item(item) # rubocop:disable Metrics/AbcSize
      sys_qty = @this_repo.system_quantity(item[:mr_sku_id], item[:location_id])
      qty = sys_qty - item[:actual_quantity].to_d
      res = RemoveMrStock.call(item[:mr_sku_id],
                               item[:location_id],
                               qty,
                               ref_no: @ref_no,
                               parent_transaction_id: destroy_transaction_id(attrs),
                               business_process_id: @business_process_id,
                               user_name: @opts[:user_name])
      return res if res.success

      failed_response("Bulk Stock Adjustment Item #{item[:id]}: Attempt to destroy stock failed - #{res.message}")
    end

    def create_stock_item(item) # rubocop:disable Metrics/AbcSize
      parent_transaction_id = create_transaction_id(attrs)
      sys_qty = @this_repo.system_quantity(item[:mr_sku_id], item[:location_id])
      qty = item[:actual_quantity].to_d - sys_qty
      res = CreateMrStock.call([item[:mr_sku_id]],
                               @business_process_id,
                               to_location_id: item[:location_id],
                               user_name: @opts[:user_name],
                               ref_no: @ref_no,
                               parent_transaction_id: parent_transaction_id,
                               quantities: [{ sku_id: item[:mr_sku_id], qty: qty }])
      return res if res.success

      failed_response("Bulk Stock Adjustment Item #{item[:id]}: Attempt to create stock failed - #{res.message}")
    end

    def attrs
      {
        business_process_id: @business_process_id,
        ref_no: @ref_no,
        user_name: @opts[:user_name]
      }
    end

    def destroy_transaction_id(attrs)
      @destroy_transaction_id ||= @this_repo.transaction_id('destroy', attrs)
    end

    def create_transaction_id(attrs)
      @create_transaction_id ||= @this_repo.transaction_id('create', attrs)
    end
  end
end
