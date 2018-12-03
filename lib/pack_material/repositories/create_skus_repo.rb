# frozen_string_literal: true

module PackMaterialApp
  class CreateSKUSRepo < BaseRepo
    def delivery_process_id
      DB[:business_processes].where(process: 'DELIVERIES').select(:id).single_value
    end

    def create_skus_for_delivery(mr_delivery_id)
      party_repo = MasterfilesApp::PartyRepo.new
      owner_party_role_id = party_repo.implementation_owner_party_role.id
      query = <<~SQL
        INSERT INTO mr_skus (mr_product_variant_id, owner_party_role_id, mr_delivery_item_batch_id,
                     batch_number, is_consignment_stock, initial_quantity)
        SELECT mr_purchase_order_items.mr_product_variant_id,
        CASE WHEN mr_delivery_terms.is_consignment_stock THEN mr_purchase_orders.supplier_party_role_id ELSE ? END,
        mr_delivery_item_batches.id,
        COALESCE(mr_internal_batch_numbers.batch_number::text, mr_delivery_item_batches.client_batch_number) AS batch_number,
        mr_delivery_terms.is_consignment_stock,
        mr_delivery_item_batches.quantity_received
        FROM mr_delivery_item_batches
        LEFT OUTER JOIN mr_internal_batch_numbers ON mr_internal_batch_numbers.id = mr_delivery_item_batches.mr_internal_batch_number_id
        JOIN mr_delivery_items ON mr_delivery_item_batches.mr_delivery_item_id = mr_delivery_items.id
        JOIN mr_purchase_order_items ON mr_delivery_items.mr_purchase_order_item_id = mr_purchase_order_items.id
        JOIN mr_purchase_orders ON mr_purchase_order_items.mr_purchase_order_id = mr_purchase_orders.id
        JOIN mr_delivery_terms ON mr_purchase_orders.mr_delivery_term_id = mr_delivery_terms.id
        WHERE mr_delivery_items.mr_delivery_id = ?
        RETURNING mr_skus.id
      SQL
      DB[query, owner_party_role_id, mr_delivery_id].select_map(:id)
    end
  end
end
