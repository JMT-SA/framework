# frozen_string_literal: true

module PackMaterialApp
  class MrStockRepo < BaseRepo
    def delivery_process_id
      DB[:business_processes].where(process: 'DELIVERIES').select(:id).single_value
    end

    def create_skus_for_delivery(mr_delivery_id)
      sku_ids = []
      items = DB[:mr_delivery_items].where(mr_delivery_id: mr_delivery_id).all
      items.each do |item|
        pv_id = item[:mr_product_variant_id]
        pv = DB[:material_resource_product_variants].where(id: pv_id).first
        fixed = pv[:use_fixed_batch_number]
        attrs = prep_item_attrs(item, pv_id)

        if fixed
          attrs[:mr_internal_batch_number_id] = pv[:mr_internal_batch_number_id]

          sku_id = find_or_create_sku(attrs)
          sku_ids << sku_id
        else
          batch_ids = DB[:mr_delivery_item_batches].where(mr_delivery_item_id: item[:id]).map(:id)
          batch_ids.each do |batch_id|
            attrs[:mr_delivery_item_batch_id] = batch_id

            sku_id = find_or_create_sku(attrs)
            sku_ids << sku_id
          end
        end
      end
      sku_ids
    end

    def find_or_create_sku(attrs)
      sku_id = DB[:mr_skus].where(attrs).get(:id)
      return sku_id if sku_id
      create(:mr_skus, attrs)
    end

    def party_repo
      MasterfilesApp::PartyRepo.new
    end

    def prep_item_attrs(item, product_variant_id)
      owner_party_role_id = party_repo.implementation_owner_party_role.id
      term_id, supplier_party_role_id = DB[:mr_purchase_orders].where(
        id: DB[:mr_purchase_order_items].where(
          id: item[:mr_purchase_order_item_id]
        ).get(:mr_purchase_order_id)
      ).get([:mr_delivery_term_id, :supplier_party_role_id])

      attrs = { mr_product_variant_id: product_variant_id }
      attrs[:is_consignment_stock] = DB[:mr_delivery_terms].where(id: term_id).get(:is_consignment_stock)
      attrs[:owner_party_role_id] = attrs[:is_consignment_stock] ? supplier_party_role_id : owner_party_role_id
      attrs
    end

    def default_receiving_bay_id
      DB[:locations].where(location_code: DEFAULT_RECEIVING_BAY_NAME).get(:id)
    end

    def find_location_id_by_code(location_code)
      return default_receiving_bay_id unless location_code
      DB[:locations].where(location_code: location_code).get(:id)
    end

    def resolve_parent_transaction_id(opts)
      if (delivery_id = opts[:delivery_id])
        DB[:mr_deliveries].where(id: delivery_id).get(:putaway_transaction_id)
      elsif (tripsheet_id = opts[:tripsheet_id])
        # transaction_for_tripsheet_id(tripsheet_id)
      else
        opts[:parent_transaction_id]
      end
    end

    def resolve_business_process_id(opts)
      if opts[:delivery_id]
        DB[:business_processes].where(process: AppConst::PROCESS_DELIVERIES).get(:id)
      elsif opts[:is_adhoc]
        DB[:business_processes].where(process: AppConst::PROCESS_ADHOC_TRANSACTIONS).get(:id)
      elsif opts[:tripsheet_id]
        DB[:business_processes].where(process: AppConst::PROCESS_VEHICLE_JOBS).get(:id)
      else
        opts[:business_process_id]
      end
    end

    def transaction_type_id_for(type)
      type_name = case type
                  when 'create'
                    TRANSACTION_TYPE_CREATE_STOCK
                  when 'adhoc'
                    TRANSACTION_TYPE_ADHOC_MOVE
                  else # when 'putaway'
                    TRANSACTION_TYPE_PUTAWAY
                  end
      DB[:mr_inventory_transaction_types].where(type_name: type_name).get(:id)
    end

    def update_delivery_receipt_id(id, receipt_id)
      update(:mr_deliveries, id, receipt_transaction_id: receipt_id)
    end

    def delivery_receipt_id(id)
      DB[:mr_deliveries].where(id: id).get(:receipt_transaction_id)
    end

    def get_delivery_sku_quantities(mr_delivery_id)
      quantities = []
      items = DB[:mr_delivery_items].where(mr_delivery_id: mr_delivery_id).all
      items.each do |item|
        pv_id = item[:mr_product_variant_id]
        pv = DB[:material_resource_product_variants].where(id: pv_id).first
        fixed = pv[:use_fixed_batch_number]

        if fixed
          int_batch_number = pv[:mr_internal_batch_number_id]
          qty = item[:quantity_received]
          sku_id = DB[:mr_skus].where(
            mr_product_variant_id: pv_id,
            mr_internal_batch_number_id: int_batch_number
          ).get(:id)
          quantities << { sku_id: sku_id, qty: qty }
        else
          batches = DB[:mr_delivery_item_batches].where(mr_delivery_item_id: item[:id]).all
          batches.each do |batch|
            batch_id = batch[:id]
            qty = batch[:quantity_received]
            sku_id = DB[:mr_skus].where(
              mr_product_variant_id: pv_id,
              mr_delivery_item_batch_id: batch_id
            ).get(:id)
            quantities << { sku_id: sku_id, qty: qty }
          end
        end
      end
      quantities
    end

    def create_sku_location_ids(sku_ids, to_location_id)
      return failed_response('Location does not exist') unless DB[:locations].where(id: to_location_id).first
      query = <<~SQL
        INSERT INTO mr_sku_locations (mr_sku_id, location_id)
        SELECT mr_skus.id, ?
        from mr_skus
        where mr_skus.id in ?
        and not exists(
          select id from mr_sku_locations
          where mr_sku_locations.location_id = ?
          and mr_sku_locations.mr_sku_id = mr_skus.id
        );
      SQL
      DB[query, to_location_id, sku_ids, to_location_id].insert
    end

    def add_sku_location_quantities(sku_quantity_groups, to_location_id)
      sku_quantity_groups.each do |grp|
        location = DB[:mr_sku_locations].where(mr_sku_id: grp[:sku_id], location_id: to_location_id)
        qty = location.get(:quantity) + grp[:qty]
        location.update(quantity: qty)
      end
    end

    def update_sku_location_quantity(sku_id, qty, location_id, add: true)
      location = DB[:mr_sku_locations].where(mr_sku_id: sku_id, location_id: location_id)
      existing_qty = location.get(:quantity)
      qty = add ? (existing_qty + qty) : (existing_qty - qty)
      if qty.positive?
        location.update(quantity: qty)
        success_response('updated successfully')
      elsif qty.zero?
        location.delete
        success_response('sku location removed')
      else
        failed_response('can not update with negative amount', qty)
      end
    end

    def sku_uom_id(sku_id)
      sku_batch_id = DB[:mr_skus].where(id: sku_id).get(:mr_delivery_item_batch_id)
      return nil unless sku_batch_id
      DB[:mr_purchase_order_items].where(
        id: DB[:mr_delivery_items].where(
          id: DB[:mr_delivery_item_batches].where(
            id: sku_batch_id
          ).select(:mr_delivery_item_id)
        ).select(:mr_purchase_order_item_id)
      ).select_map(:inventory_uom_id).first
    end
  end
end
