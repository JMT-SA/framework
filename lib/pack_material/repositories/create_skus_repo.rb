# frozen_string_literal: true

module PackMaterialApp
  class CreateSKUSRepo < BaseRepo
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
  end
end
