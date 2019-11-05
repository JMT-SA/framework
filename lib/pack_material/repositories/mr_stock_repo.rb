# frozen_string_literal: true

module PackMaterialApp
  class MrStockRepo < BaseRepo # rubocop:disable Metrics/ClassLength
    def delivery_process_id
      DB[:business_processes].where(process: 'DELIVERIES').select(:id).single_value
    end

    def find_mr_delivery(id)
      PackMaterialApp::ReplenishRepo.new.find_mr_delivery(id)
    end

    def create_skus_for_delivery(mr_delivery_id)
      sku_ids = []
      items = DB[:mr_delivery_items].where(mr_delivery_id: mr_delivery_id).all
      items.each do |item|
        sku_ids << create_delivery_item_skus(item)
      end
      sku_ids.flatten
    end

    def create_delivery_item_skus(item) # rubocop:disable Metrics/AbcSize
      pv_id = item[:mr_product_variant_id]
      pv = DB[:material_resource_product_variants].where(id: pv_id).first
      attrs = prep_item_attrs(item, pv_id)

      if pv[:use_fixed_batch_number]
        attrs[:mr_internal_batch_number_id] = pv[:mr_internal_batch_number_id]
        find_or_create_sku(attrs)
      else
        sku_ids = []
        batch_ids = DB[:mr_delivery_item_batches].where(mr_delivery_item_id: item[:id]).map(:id)
        batch_ids.each do |batch_id|
          attrs[:mr_delivery_item_batch_id] = batch_id
          sku_ids << find_or_create_sku(attrs)
        end
        sku_ids
      end
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
      term_id, supplier_party_role_id = DB[:mr_purchase_orders].where(
        id: DB[:mr_purchase_order_items].where(
          id: item[:mr_purchase_order_item_id]
        ).get(:mr_purchase_order_id)
      ).get(%i[mr_delivery_term_id supplier_party_role_id])
      consignment = DB[:mr_delivery_terms].where(id: term_id).get(:is_consignment_stock)
      {
        mr_product_variant_id: product_variant_id,
        owner_party_role_id: consignment ? supplier_party_role_id : party_repo.implementation_owner_party_role.id,
        is_consignment_stock: consignment
      }
    end

    def find_location_id_by_code(location_long_code)
      DB[:locations].where(location_long_code: location_long_code).get(:id)
    end

    def resolve_parent_transaction_id(opts)
      if (delivery_id = opts[:delivery_id])
        DB[:mr_deliveries].where(id: delivery_id).get(:putaway_transaction_id)
        # elsif (vehicle_job_id = opts[:vehicle_job_id])
        # transaction_for_vehicle_job_id(vehicle_job_id)
      else
        opts[:parent_transaction_id]
      end
    end

    def resolve_business_process_id(opts)
      return nil unless opts[:delivery_id] || opts[:is_adhoc] || opts[:vehicle_job_id]

      process = if opts[:delivery_id]
                  AppConst::PROCESS_DELIVERIES
                elsif opts[:is_adhoc]
                  AppConst::PROCESS_ADHOC_TRANSACTIONS
                else
                  AppConst::PROCESS_VEHICLE_JOBS
                end
      DB[:business_processes].where(process: process).get(:id)
    end

    def resolve_ref_no(opts)
      if (del_id = opts[:delivery_id])
        DB[:mr_deliveries].where(id: del_id).get(:delivery_number)
      elsif (trip_id = opts[:vehicle_job_id])
        DB[:vehicle_jobs].where(id: trip_id).get(:tripsheet_number)
      end
    end

    def transaction_type_id_for(type)
      type_name = case type
                  when 'create'
                    TRANSACTION_TYPE_CREATE_STOCK
                  when 'adhoc'
                    TRANSACTION_TYPE_ADHOC_MOVE
                  when 'destroy'
                    TRANSACTION_TYPE_REMOVE_STOCK
                  when 'load'
                    TRANSACTION_TYPE_LOAD_VEHICLE
                  when 'offload'
                    TRANSACTION_TYPE_OFFLOAD_VEHICLE
                  else # when 'putaway'
                    TRANSACTION_TYPE_PUTAWAY
                  end
      DB[:mr_inventory_transaction_types].where(type_name: type_name).get(:id)
    end

    def update_delivery_receipt_id(id, receipt_id)
      return failed_response('Delivery does not exist') unless exists?(:mr_deliveries, id: id)

      update(:mr_deliveries, id, receipt_transaction_id: receipt_id)
      success_response('ok')
    end

    def update_delivery_putaway_id(id, putaway_id)
      update(:mr_deliveries, id, putaway_transaction_id: putaway_id)
    end

    def delivery_receipt_id(id)
      DB[:mr_deliveries].where(id: id).get(:receipt_transaction_id)
    end

    def get_delivery_sku_quantities(mr_delivery_id) # rubocop:disable Metrics/AbcSize
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
      return failed_response("Location does not exist (#{to_location_id})") unless exists?(:locations, id: to_location_id)
      return failed_response("Location can not store stock (#{to_location_id})") unless stock_location?(to_location_id)

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
      success_response('ok')
    end

    def stock_location?(location_id)
      DB[:locations].where(id: location_id).get(:can_store_stock)
    end

    # @param [Object] sku_quantity_groups qty should be a float
    def add_sku_location_quantities(sku_quantity_groups, to_location_id)
      return failed_response('No SKU quantities given') unless sku_quantity_groups.any?

      sku_quantity_groups.each do |grp|
        location = DB[:mr_sku_locations].where(mr_sku_id: grp[:sku_id], location_id: to_location_id)
        return failed_response('No SKUs at location') unless location.first

        qty = location.get(:quantity) + grp[:qty]
        location.update(quantity: qty)
      end
      success_response('ok')
    end

    def update_sku_location_quantity(sku_id, qty, location_id, add: true) # rubocop:disable Metrics/AbcSize
      location = DB[:mr_sku_locations].where(mr_sku_id: sku_id, location_id: location_id)
      return failed_response('No SKUs at location') unless location.first

      existing_qty = location.get(:quantity)
      qty = add ? (existing_qty + qty) : (existing_qty - qty)
      if qty.positive?
        location.update(quantity: qty)
        success_response('updated successfully')
      elsif qty.zero?
        location.delete
        success_response('SKU location removed')
      else
        failed_response('can not update with negative amount', qty)
      end
    end

    def sku_uom_id(sku_id)
      variant_id = DB[:mr_skus].where(id: sku_id).get(:mr_product_variant_id)
      return nil unless variant_id

      st_id = DB[:material_resource_product_variants].where(id: variant_id).get(:sub_type_id)
      DB[:material_resource_sub_types].where(id: st_id).get(:inventory_uom_id)
    end

    def activate_mr_inventory_transaction(parent_transaction_id)
      return failed_response('Invalid Parent Transaction ID') unless exists?(:mr_inventory_transactions, id: parent_transaction_id)

      DB[:mr_inventory_transactions].where(id: parent_transaction_id).update(active: true)
      success_response('ok')
    end

    def update_vehicle_job_transaction_id(id, transaction_id, type)
      update(:vehicle_jobs, id, load_transaction_id: transaction_id) if type == 'load'
      update(:vehicle_jobs, id, offload_transaction_id: transaction_id) if type == 'offload'
    end
  end
end
