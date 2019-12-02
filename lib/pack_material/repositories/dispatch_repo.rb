# frozen_string_literal: true

module PackMaterialApp
  class DispatchRepo < BaseRepo # rubocop:disable Metrics/ClassLength
    build_for_select :mr_goods_returned_notes,
                     label: :created_by,
                     value: :id,
                     no_active_check: true,
                     order_by: :created_by

    crud_calls_for :mr_goods_returned_notes, name: :mr_goods_returned_note, wrapper: MrGoodsReturnedNote

    build_for_select :mr_goods_returned_note_items,
                     label: :remarks,
                     value: :id,
                     no_active_check: true,
                     order_by: :remarks

    crud_calls_for :mr_goods_returned_note_items, name: :mr_goods_returned_note_item, wrapper: MrGoodsReturnedNoteItem

    def find_mr_goods_returned_note(id)
      find_with_association(:mr_goods_returned_notes, id,
                            wrapper: MrGoodsReturnedNote,
                            parent_tables: [
                              { parent_table: :mr_deliveries,
                                columns: :delivery_number,
                                flatten_columns: { delivery_number: :delivery_number } }
                            ],
                            lookup_functions: [
                              { function: :fn_current_status, args: ['mr_goods_returned_notes', :id], col_name: :status }
                            ])
    end

    def create_mr_goods_returned_note_item(attrs)
      attrs = attrs.to_h
      if (batch_id = attrs[:mr_delivery_item_batch_id])
        item_id = DB[:mr_delivery_item_batches].where(id: batch_id).get(:mr_delivery_item_id)
        attrs[:mr_delivery_item_id] = item_id
      end
      create(:mr_goods_returned_note_items, attrs)
    end

    def find_mr_goods_returned_note_item(id)
      item = DB["SELECT mr_goods_returned_note_items.*,
                    coalesce(ms.sku_number, msk.sku_number) as sku_number,
                    material_resource_product_variants.product_variant_code,
                    material_resource_product_variants.product_variant_number,
                    fn_current_status('mr_goods_returned_note_items', mr_goods_returned_note_items.id) AS status,
                    mr_goods_returned_note_items.created_at,
                    mr_goods_returned_note_items.updated_at
                  FROM mr_goods_returned_note_items
                  LEFT JOIN mr_delivery_item_batches ON mr_delivery_item_batches.id = mr_goods_returned_note_items.mr_delivery_item_batch_id
                  LEFT JOIN mr_delivery_items ON mr_delivery_items.id = mr_goods_returned_note_items.mr_delivery_item_id
                  LEFT JOIN mr_deliveries on mr_deliveries.id = mr_delivery_items.mr_delivery_id
                  JOIN mr_goods_returned_notes ON mr_goods_returned_notes.id = mr_goods_returned_note_items.mr_goods_returned_note_id
                  LEFT JOIN mr_skus ms on mr_delivery_item_batches.id = ms.mr_delivery_item_batch_id
                  LEFT JOIN mr_skus msk on mr_delivery_items.mr_product_variant_id = msk.mr_product_variant_id
                  LEFT JOIN material_resource_product_variants on mr_delivery_items.mr_product_variant_id = material_resource_product_variants.id
                  WHERE mr_goods_returned_note_items.id = ?", id].first
      MrGoodsReturnedNoteItem.new(item)
    end

    def grn_item_hashes(grn_id)
      item_collection = []
      items = DB[:mr_goods_returned_note_items].where(mr_goods_returned_note_id: grn_id).all
      items.each do |item|
        batch_id = item[:mr_delivery_item_batch_id]
        record = batch_id ? DB[:mr_delivery_item_batches].where(id: batch_id) : DB[:mr_delivery_items].where(id: item[:mr_delivery_item_id])
        sku_id = record.get(:mr_sku_id)
        item_collection << item.merge(sku_id: sku_id)
      end
      item_collection
    end

    def grn_business_process_id
      DB[:business_processes].where(process: AppConst::PROCESS_GOODS_RETURN).get(:id)
    end

    def validate_grn_stock_levels(grn_id) # rubocop:disable Metrics/AbcSize
      grn = DB[:mr_goods_returned_notes].where(id: grn_id)
      item_collection = []
      grn_items = DB[:mr_goods_returned_note_items].where(mr_goods_returned_note_id: grn_id).all
      # grn_item = DB[:mr_goods_returned_note_items].where(mr_goods_returned_note_id: grn_id).all[0]
      grn_items.each do |grn_item|
        batch_id = grn_item[:mr_delivery_item_batch_id]
        record = batch_id ? DB[:mr_delivery_item_batches].where(id: batch_id) : DB[:mr_delivery_items].where(id: grn_item[:mr_delivery_item_id])
        sku_id = record.get(:mr_sku_id)
        avail_qty = DB[:mr_sku_locations].where(location_id: grn.get(:dispatch_location_id), mr_sku_id: sku_id).get(:quantity) || AppConst::BIG_ZERO

        attrs = {
          sku_id: sku_id,
          qty: grn_item[:quantity_returned]
        }
        item_collection << attrs
        next if avail_qty > grn_item[:quantity_returned]

        return failed_response 'Quantity returned can not be more than the quantity received on the delivery item'
      end
      success_response('OK', item_collection)
    end

    def dispatch_locations
      location_type_id = DB[:location_types].where(location_type_code: AppConst::LOCATION_TYPES_DISPATCH).get(:id)
      MasterfilesApp::LocationRepo.new.for_select_locations(where: { location_type_id: location_type_id, can_store_stock: true })
    end

    def goods_returned_note_item_options(grn_id) # rubocop:disable Metrics/AbcSize
      del_id = DB[:mr_goods_returned_notes].where(id: grn_id).get(:mr_delivery_id)
      items = DB[:mr_delivery_items].where(mr_delivery_id: del_id).all
      delivery = DB[:mr_deliveries].where(id: del_id).first
      collection = []
      items.each do |item|
        batches = DB[:mr_delivery_item_batches].where(mr_delivery_item_id: item[:id]).all
        pv = DB[:material_resource_product_variants].where(id: item[:mr_product_variant_id]).first
        pv_number = pv[:product_variant_code]
        del_no = delivery[:delivery_number]
        if batches.any?
          batches.each do |r|
            next if DB[:mr_goods_returned_note_items].where(
              mr_goods_returned_note_id: grn_id,
              mr_delivery_item_batch_id: r[:id]
            ).first

            qty = UtilityFunctions.delimited_number(r[:quantity_received], delimiter: '', no_decimals: 2)
            sku_number = DB[:mr_skus].where(id: r[:mr_sku_id]).get(:sku_number)
            collection << ["#{pv_number}, #{qty} (DEL:#{del_no}, SKU:#{sku_number})", "batch_#{r[:id]}"]
          end
        else
          unless DB[:mr_goods_returned_note_items].where(mr_goods_returned_note_id: grn_id, mr_delivery_item_id: item[:id]).first
            qty = UtilityFunctions.delimited_number(item[:quantity_received], delimiter: '', no_decimals: 2)
            sku_number = DB[:mr_skus].where(id: item[:mr_sku_id]).get(:sku_number)
            collection << ["#{pv_number}, #{qty} (DEL:#{del_no}, SKU:#{sku_number})", "item_#{item[:id]}"]
          end
        end
      end
      collection
    end

    def inline_update_goods_returned_note(id, attrs)
      update(:mr_goods_returned_note_items, id, "#{attrs[:column_name]}": attrs[:column_value])
    end

    def grn_complete_invoice(id, attrs)
      update(:mr_goods_returned_notes, id,
             invoice_error: false,
             invoice_completed: true,
             erp_purchase_order_number: attrs[:purchase_order_number],
             erp_purchase_invoice_number: attrs[:purchase_invoice_number])
    end
  end
end
