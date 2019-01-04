# frozen_string_literal: true

module PackMaterialApp
  class CreateMrStockRepo < BaseRepo
    def find_location_id_by_code(location_code)
      return DB[:locations].where(location_code: 'RECEIVING BAY').select(:id).single_value unless location_code
      DB[:locations].where(location_code: location_code).select(:id).single_value
    end

    def create_stock_transaction_type_id
      DB[:mr_inventory_transaction_types].where(type_name: 'CREATE STOCK').select(:id).single_value
    end

    def update_delivery_receipt_id(id, receipt_id)
      update(:mr_deliveries, id, receipt_transaction_id: receipt_id)
    end

    def find_or_create_sku_location_ids(sku_ids, to_location_id) # rubocop:disable Metrics/AbcSize
      # find existing sku_locations
      #
      # TODO: SHOULD WE BE LOOKING FOR EXISTING SKU LOCATIONS BY SKU NUMBER OR BY SKU ID?
      existing_sku_locations = DB[:mr_sku_locations].where(location_id: to_location_id, mr_sku_id: sku_ids).all
      existing_sku_ids = existing_sku_locations.map { |r| r[:mr_sku_id] }

      instance = {
        skus: [],
        sku_location_ids: []
      }
      # update quantities for existing sku locations
      existing_sku_locations.each do |loc|
        sku = find_hash(:mr_skus, loc[:mr_sku_id])
        sku_qty = 0 # TODO: this needs to be sent in per MRProduct Variant

        qty = loc[:quantity] + sku_qty
        update(:mr_sku_locations, loc[:id], quantity: qty)

        instance[:skus] << sku
      end
      instance[:sku_location_ids] = existing_sku_locations.map { |r| r[:id] }

      # create new sku_locations
      new_sku_ids = sku_ids - existing_sku_ids
      new_sku_ids.each do |sku_id|
        sku = find_hash(:mr_skus, sku_id)
        # qty = sku[:initial_quantity]
        qty = 0 # TODO: this needs to be sent in per MRProduct Variant
        instance[:skus] << sku

        sku_loc_id = create(:mr_sku_locations, location_id: to_location_id, quantity: qty, mr_sku_id: sku_id)
        instance[:sku_location_ids] << sku_loc_id
      end
      success_response 'Successfully created SKU locations', instance
    end
  end
end
