# frozen_string_literal: true

module PackMaterialApp
  class BulkStockAdjustmentRepo < BaseRepo
    def system_quantity(mr_sku_id, location_id)
      transaction_repo.system_quantity(mr_sku_id: mr_sku_id, location_id: location_id)
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
      separated_items = { destroy_stock_items: [], create_stock_items: [] }
      all_hash(:mr_bulk_stock_adjustment_items, mr_bulk_stock_adjustment_id: bulk_stock_adjustment_id).each do |item|
        sys_qty = system_quantity(item[:mr_sku_id], item[:location_id])
        sys_qty > item[:actual_quantity].to_d ? separated_items[:destroy_stock_items] << item : separated_items[:create_stock_items] << item
      end
      separated_items
    end

    # @param [Array] sku_ids
    # @param [Integer] loc_id - remove: from_location, add: to_location, move: from/to_location
    # @param [Integer] move_loc_id - move: from/to_location
    def any_in_progress?(sku_ids: [], loc_id: nil, move_loc_id: nil)
      return false unless DB[:mr_bulk_stock_adjustments].where(signed_off: false).single_value

      in_use = sku_location_pair_in_use(sku_ids, loc_id)
      in_use ||= sku_location_pair_in_use(sku_ids, move_loc_id) if move_loc_id
      in_use
    end

    def sku_location_pair_in_use(sku_ids, location_id)
      DB[:mr_bulk_stock_adjustment_items].where(
        mr_bulk_stock_adjustment_id: DB[:mr_bulk_stock_adjustments].where(
          signed_off: false
        ).select_map(:id),
        location_id: location_id,
        mr_sku_id: sku_ids
      ).select_map(:id).any?
    end

    def mr_stock_repo
      PackMaterialApp::MrStockRepo.new
    end

    def transaction_repo
      PackMaterialApp::TransactionsRepo.new
    end

    def apply_product_variant_prices(bulk_stock_adjustment_id)
      return failed_response('No Bulk Stock Adjustment ID') unless bulk_stock_adjustment_id

      prices = DB[:mr_bulk_stock_adjustment_prices].where(mr_bulk_stock_adjustment_id: bulk_stock_adjustment_id)
      prices.all.map { |r| [r[:mr_product_variant_id], r[:stock_adj_price]] }.each do |v_id, price|
        next unless price

        variant = DB[:material_resource_product_variants].where(id: v_id)
        variant.update(stock_adj_price: price)
      end
      success_response('ok')
    end
  end
end
