# frozen_string_literal: true

module PackMaterialApp
  class TransactionsRepo < BaseRepo # rubocop:disable Metrics/ClassLength
    build_for_select :mr_inventory_transactions,
                     label: :created_by,
                     value: :id,
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

    build_for_select :mr_bulk_stock_adjustments,
                     label: :id,
                     value: :id,
                     order_by: :id
    build_inactive_select :mr_bulk_stock_adjustments,
                          label: :id,
                          value: :id,
                          order_by: :id

    crud_calls_for :mr_bulk_stock_adjustments, name: :mr_bulk_stock_adjustment, wrapper: MrBulkStockAdjustment

    build_for_select :mr_bulk_stock_adjustment_items,
                     label: :id,
                     value: :id,
                     order_by: :id
    build_inactive_select :mr_bulk_stock_adjustment_items,
                          label: :id,
                          value: :id,
                          order_by: :id

    crud_calls_for :mr_bulk_stock_adjustment_items, name: :mr_bulk_stock_adjustment_item, wrapper: MrBulkStockAdjustmentItem
    crud_calls_for :mr_bulk_stock_adjustment_prices,
                   name: :mr_bulk_stock_adjustment_price,
                   wrapper: MrBulkStockAdjustmentPrice,
                   exclude: %i[create update delete]

    build_for_select :business_processes,
                     label: :process,
                     value: :id,
                     no_active_check: true,
                     order_by: :process

    def for_select_bsa_business_processes
      for_select_business_processes(where: { id: valid_bulk_stock_adjustment_business_process_ids })
    end

    def create_mr_sku_location(attrs)
      stock_location = DB[:locations].where(id: attrs[:location_id]).get(:can_store_stock)
      return failed_response('Location can not store stock') unless stock_location

      create(:mr_sku_locations, attrs)
    end

    def create_mr_bulk_stock_adjustment(attrs)
      process_id = attrs[:business_process_id]
      return failed_response('Business Process is not allowed') unless valid_bulk_stock_adjustment_business_process_ids.include?(process_id)

      create(:mr_bulk_stock_adjustments, business_process_id: process_id, ref_no: attrs[:ref_no])
    end

    def valid_bulk_stock_adjustment_business_process_ids
      processes = [
        AppConst::PROCESS_BULK_STOCK_ADJUSTMENTS,
        AppConst::PROCESS_STOCK_TAKE,
        # AppConst::PROCESS_STOCK_TAKE_ON, # NOTE: This is only for initial Stock Take on, this should never be used again
        AppConst::PROCESS_STOCK_SALES
      ]
      DB[:business_processes].where(process: processes).map(:id)
    end

    def pack_material_storage_type_id
      DB[:location_storage_types].where(storage_type_code: PackMaterialApp::DOMAIN_NAME).get(:id)
    end

    def delete_mr_bulk_stock_adjustment(id)
      DB[:mr_bulk_stock_adjustment_items].where(mr_bulk_stock_adjustment_id: id).delete
      DB[:mr_bulk_stock_adjustments_sku_numbers].where(mr_bulk_stock_adjustment_id: id).delete
      DB[:mr_bulk_stock_adjustments_locations].where(mr_bulk_stock_adjustment_id: id).delete
      DB[:mr_bulk_stock_adjustment_prices].where(mr_bulk_stock_adjustment_id: id).delete
      DB[:mr_bulk_stock_adjustments].where(id: id).delete
    end

    def create_mr_bulk_stock_adjustment_item(attrs) # rubocop:disable Metrics/AbcSize
      sku_id = attrs[:mr_sku_id]
      location_id = attrs[:location_id]

      mr_product_variant_id = DB[:mr_skus].where(id: sku_id).get(:mr_product_variant_id)
      variant = DB[:material_resource_product_variants].where(id: mr_product_variant_id)
      product_variant_number = variant.get(:product_variant_number)
      product_variant_code = variant.get(:product_variant_code)
      old_product_code = variant.get(:old_product_code)
      sub_type_id = variant.get(:sub_type_id)

      sub_type = DB[:material_resource_sub_types].where(id: sub_type_id)
      mr_sub_type_name = sub_type.get(:sub_type_name)
      mr_type_id = sub_type.get(:material_resource_type_id)
      mr_type_name = DB[:material_resource_types].where(id: mr_type_id).get(:type_name)
      inventory_uom_id = sub_type.get(:inventory_uom_id)
      inventory_uom_code = DB[:uoms].where(id: inventory_uom_id).get(:uom_code)
      system_qty = system_quantity(attrs)

      item_id = create(:mr_bulk_stock_adjustment_items,
                       mr_bulk_stock_adjustment_id: attrs[:mr_bulk_stock_adjustment_id],
                       sku_number: DB[:mr_skus].where(id: sku_id).get(:sku_number),
                       mr_sku_id: sku_id,
                       location_id: location_id,
                       product_variant_number: product_variant_number,
                       mr_type_name: mr_type_name,
                       mr_sub_type_name: mr_sub_type_name,
                       product_variant_code: product_variant_code,
                       old_product_code: old_product_code,
                       inventory_uom_id: inventory_uom_id,
                       inventory_uom_code: inventory_uom_code,
                       system_quantity: system_qty,
                       location_long_code: DB[:locations].where(id: location_id).get(:location_long_code))

      create_mr_bulk_stock_adjustment_prices(mr_bulk_stock_adjustment_id: attrs[:mr_bulk_stock_adjustment_id], mr_product_variant_id: mr_product_variant_id)
      item_id
    end

    def create_mr_bulk_stock_adjustment_prices(attrs)
      DB[:mr_bulk_stock_adjustment_prices].insert(attrs) unless exists?(:mr_bulk_stock_adjustment_prices, attrs)
    end

    def delete_mr_bulk_stock_adjustment_item(id)
      item = DB[:mr_bulk_stock_adjustment_items].where(id: id)
      pv_number = item.get(:product_variant_number)
      parent_id = item.get(:mr_bulk_stock_adjustment_id)

      item.delete
      delete_mr_bulk_stock_adjustment_prices(parent_id, pv_number)
    end

    def delete_mr_bulk_stock_adjustment_prices(parent_id, pv_number)
      item = DB[:mr_bulk_stock_adjustment_items].where(
        mr_bulk_stock_adjustment_id: parent_id,
        product_variant_number: pv_number
      ).single_value
      return nil if item

      DB[:mr_bulk_stock_adjustment_prices].where(
        mr_bulk_stock_adjustment_id: parent_id,
        mr_product_variant_id: DB[:material_resource_product_variants].where(
          product_variant_number: pv_number
        ).get(:id)
      ).delete
    end

    def system_quantity(attrs)
      sku_location = DB[:mr_sku_locations].where(mr_sku_id: attrs[:mr_sku_id], location_id: attrs[:location_id]).first
      sku_location ? sku_location[:quantity].to_d : 0.0
    end

    def get_sku_location_info_ids(sku_location_id)
      sku_location = DB[:mr_sku_locations].where(id: sku_location_id)
      {
        sku_number: sku_number_for_sku_location(sku_location_id),
        sku_id: sku_location.get(:mr_sku_id),
        location_id: sku_location.get(:location_id)
      }
    end

    def bulk_stock_adjustment_sku_numbers(bulk_stock_adjustment_id)
      DB[:mr_skus].where(
        id: bulk_stock_adjustment_sku_ids(bulk_stock_adjustment_id)
      ).map { |r| ["#{r[:sku_number]}: #{product_code(r[:mr_product_variant_id])}", r[:id]] }
    end

    def product_code(product_variant_id)
      DB[:material_resource_product_variants].where(id: product_variant_id).get(:product_variant_code)
    end

    def bulk_stock_adjustment_locations(bulk_stock_adjustment_id)
      DB[:locations].where(
        id: bulk_stock_adjustment_location_ids(bulk_stock_adjustment_id)
      ).map { |r| [r[:location_long_code], r[:id]] }
    end

    def bulk_stock_adjustment_location_ids(bulk_stock_adjustment_id)
      DB[:mr_bulk_stock_adjustments_locations].where(
        mr_bulk_stock_adjustment_id: bulk_stock_adjustment_id
      ).select_map(:location_id)
    end

    def bulk_stock_adjustment_sku_ids(bulk_stock_adjustment_id)
      DB[:mr_bulk_stock_adjustments_sku_numbers].where(
        mr_bulk_stock_adjustment_id: bulk_stock_adjustment_id
      ).select_map(:mr_sku_id)
    end

    def bulk_stock_adjustment_id_from_number(stock_adjustment_number)
      DB[:mr_bulk_stock_adjustments].where(
        stock_adjustment_number: stock_adjustment_number
      ).get(:id)
    end

    def bulk_stock_adjustment_number_from_id(bulk_stock_adjustment_id)
      DB[:mr_bulk_stock_adjustments].where(
        id: bulk_stock_adjustment_id
      ).get(:stock_adjustment_number)
    end

    def link_mr_skus(bulk_stock_adjustment_id, mr_sku_ids)
      DB[:mr_bulk_stock_adjustments_sku_numbers].where(mr_bulk_stock_adjustment_id: bulk_stock_adjustment_id).delete
      mr_sku_ids.each do |mr_sku_id|
        DB[:mr_bulk_stock_adjustments_sku_numbers].insert(mr_bulk_stock_adjustment_id: bulk_stock_adjustment_id, mr_sku_id: mr_sku_id)
      end
    end

    def link_locations(bulk_stock_adjustment_id, location_ids)
      DB[:mr_bulk_stock_adjustments_locations].where(mr_bulk_stock_adjustment_id: bulk_stock_adjustment_id).delete
      location_ids.each do |location_id|
        DB[:mr_bulk_stock_adjustments_locations].insert(mr_bulk_stock_adjustment_id: bulk_stock_adjustment_id, location_id: location_id)
      end
    end

    def sku_number_for_sku_location(sku_location_id)
      DB[:mr_skus].where(id: DB[:mr_sku_locations].where(id: sku_location_id).get(:mr_sku_id)).get(:sku_number)
    end

    def existing_sku_locations_for(sku_id, location_id)
      DB[:mr_sku_locations].where(mr_sku_id: sku_id, location_id: location_id).all
    end

    def sku_id_for_sku_number(sku_number)
      DB[:mr_skus].where(sku_number: sku_number).get(:id)
    end

    def allowed_locations
      ancestor_id = DB[:locations].where(location_long_code: AppConst::LOCATIONS_PM).get(:id)
      descendant_ids = location_repo.descendants_for_ancestor_id(ancestor_id) - [ancestor_id]

      type_id = DB[:location_storage_types].where(storage_type_code: PackMaterialApp::DOMAIN_NAME).get(:id)
      DB[:locations].where(primary_storage_type_id: type_id, id: descendant_ids).map { |r| [r[:location_long_code], r[:id]] }
    end

    def location_repo
      MasterfilesApp::LocationRepo.new
    end

    def complete_mr_bulk_stock_adjustment(id)
      update(:mr_bulk_stock_adjustments, id, completed: true)
    end

    def reopen_mr_bulk_stock_adjustment(id)
      update(:mr_bulk_stock_adjustments, id, completed: false)
    end

    def approve_mr_bulk_stock_adjustment(id)
      update(:mr_bulk_stock_adjustments, id, approved: true)
    end

    def decline_mr_bulk_stock_adjustment(id)
      update(:mr_bulk_stock_adjustments, id, approved: false, completed: false)
    end

    def signed_off_mr_bulk_stock_adjustment(id)
      update(:mr_bulk_stock_adjustments, id, signed_off: true)
    end

    def find_mr_bulk_stock_adjustment_item(id)
      find_with_association(:mr_bulk_stock_adjustment_items, id,
                            parent_tables: [{ parent_table: :uoms,
                                              foreign_key: :inventory_uom_id,
                                              flatten_columns: { uom_code: :inventory_uom_code } }],
                            wrapper: PackMaterialApp::MrBulkStockAdjustmentItem)
    end

    def rmd_update_bulk_stock_adjustment_item(attrs)
      item = DB[:mr_bulk_stock_adjustment_items].where(mr_bulk_stock_adjustment_id: attrs[:mr_bulk_stock_adjustment_id],
                                                       mr_sku_id: attrs[:mr_sku_id],
                                                       location_id: attrs[:location_id]).first
      return failed_response('Item does not exist') unless item || stock_take_on?(attrs[:mr_bulk_stock_adjustment_id])

      item_id = if item.nil?
                  create_mr_bulk_stock_adjustment_item(attrs)
                else
                  item[:id]
                end

      update(:mr_bulk_stock_adjustment_items, item_id, actual_quantity: attrs[:actual_quantity])
      success_response('ok', item_id)
    end

    def stock_take_on?(mr_bulk_stock_adjustment_id)
      DB[:mr_bulk_stock_adjustments].where(id: mr_bulk_stock_adjustment_id).get(:business_process_id) == stock_take_on_business_process_id
    end

    def stock_take_on_business_process_id
      DB[:business_processes].where(process: AppConst::PROCESS_STOCK_TAKE_ON).get(:id)
    end

    def stock_adjustment_progress_report_values(bulk_stock_adjustment_id, sku_id, location_id) # rubocop:disable Metrics/AbcSize
      return nil unless bulk_stock_adjustment_id && sku_id && location_id

      total_items = DB[:mr_bulk_stock_adjustment_items].where(mr_bulk_stock_adjustment_id: bulk_stock_adjustment_id).all
      sku = DB[:mr_skus].where(id: sku_id).first
      {
        total_items: total_items,
        done: total_items.reject { |r| r[:actual_quantity].nil? }.count,
        sku: sku,
        product_variant_code: DB[:material_resource_product_variants].where(id: sku[:mr_product_variant_id]).get(:product_variant_code),
        item: DB[:mr_bulk_stock_adjustment_items].where(
          mr_bulk_stock_adjustment_id: bulk_stock_adjustment_id,
          mr_sku_id: sku_id,
          location_id: location_id
        ).first
      }
    end

    def inline_update_bulk_stock_adjustment_item(id, attrs)
      update(:mr_bulk_stock_adjustment_items, id, "#{attrs[:column_name]}": attrs[:column_value])
    end

    def replenish_repo
      ReplenishRepo.new
    end

    def bulk_stock_adjustment_list_items(bulk_stock_adjustment_id)
      all(:mr_bulk_stock_adjustment_items, MrBulkStockAdjustmentItem, mr_bulk_stock_adjustment_id: bulk_stock_adjustment_id)
    end

    def set_price_adjustment_inline(id, attrs)
      bsa_price = DB[:mr_bulk_stock_adjustment_prices].where(id: id)
      bsa_price.update(stock_adj_price: attrs[:column_value])
    end

    def process_id(process_name)
      DB[:business_processes].where(process: process_name).get(:id)
    end

    def html_adhoc_stock_move_report(transaction_item_id)
      return nil unless transaction_item_id

      item = DB[:mr_inventory_transaction_items].where(id: transaction_item_id)
      <<~HTML
        ADHOC STOCK MOVE: Transaction (#{item.get(:mr_inventory_transaction_id)})<br>
        Last scan details:<br>
        SKU (#{replenish_repo.sku_number_from_id(item.get(:mr_sku_id))})<br>
        FROM LOC: #{replenish_repo.location_long_code_from_location_id(item.get(:from_location_id))}<br>
        TO LOC: #{replenish_repo.location_long_code_from_location_id(item.get(:to_location_id))}<br>
        QTY: #{UtilityFunctions.delimited_number(item.get(:quantity), delimiter: '')} items.<br>
      HTML
    end
  end
end
