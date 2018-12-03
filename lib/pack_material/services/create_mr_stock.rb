# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize

module PackMaterialApp
  class CreateMrStock < BaseService
    def initialize(sku_ids = [], business_process_id = nil, location_code: nil, delivery_id: nil, ref_no: nil, parent_transaction_id: nil)
      @repo = CreateMrStockRepo.new
      @transaction_repo = PackMaterialApp::TransactionsRepo.new
      @sku_ids = sku_ids
      @business_process_id = business_process_id
      @to_location_id = @repo.find_location_id_by_code(location_code)
      @delivery_id = delivery_id
      @ref_no = ref_no
      @parent_transaction_id = parent_transaction_id
    end

    def call
      return failed_response 'Stock can not be created without sku_ids' unless @sku_ids.any?

      unless @parent_transaction_id
        type_id = @repo.create_stock_transaction_type_id
        attrs = {
          mr_inventory_transaction_type_id: type_id,
          to_location_id: @to_location_id,
          business_process_id: @business_process_id,
          ref_no: @ref_no,
          is_adhoc: @delivery_id.nil?,
          created_by: 'SYSTEM'
        }
        @parent_transaction_id = @transaction_repo.create_mr_inventory_transaction(attrs)
      end

      @repo.update_delivery_receipt_id(@delivery_id, @parent_transaction_id) if @delivery_id

      result = @repo.find_or_create_sku_location_ids(@sku_ids, @to_location_id)
      if result.success
        skus = result[:instance][:skus]
        skus.each do |sku|
          uom_id = nil
          if sku[:mr_delivery_item_batch_id]
            uom_id = DB[:mr_purchase_order_items].where(
              id: DB[:mr_delivery_items].where(
                id: DB[:mr_delivery_item_batches].where(
                  id: sku[:mr_delivery_item_batch_id]
                ).select(:mr_delivery_item_id)
              ).select(:mr_purchase_order_item_id)
            ).select_map(:inventory_uom_id).first
          end

          @transaction_repo.create_mr_inventory_transaction_item(
            mr_inventory_transaction_id: @parent_transaction_id,
            mr_sku_id: sku[:id],
            inventory_uom_id: uom_id,
            quantity: sku[:initial_quantity]
          )
        end
      else
        result
      end
    end
  end
end