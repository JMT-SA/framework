# frozen_string_literal: true

module PackMaterialApp
  class PurchaseInvoiceRepo < BaseRepo
    def find_mr_delivery(id)
      PackMaterialApp::ReplenishRepo.new.find_mr_delivery(id)
    end

    def get_supplier_erp_number(delivery_id)
      DB[:suppliers].where(
        party_role_id: DB[:mr_purchase_orders].where(
          id: DB[:mr_purchase_order_items].where(
            id: DB[:mr_delivery_items].where(mr_delivery_id: delivery_id).get(:mr_purchase_order_item_id)
          ).get(:mr_purchase_order_id)
        ).get(:supplier_party_role_id)
      ).get(:erp_supplier_number)
    end

    def costs_for_delivery(delivery_id)
      DB[:mr_purchase_invoice_costs]
        .join(:mr_cost_types, id: :mr_cost_type_id)
        .where(mr_delivery_id: delivery_id)
        .select(:cost_type_code, :amount, :account_code)
        .all
    end

    def po_account_code_for_delivery(delivery_id)
      DB[:mr_delivery_items]
        .join(:mr_purchase_order_items, id: :mr_purchase_order_item_id)
        .join(:mr_purchase_orders, id: :mr_purchase_order_id)
        .where(mr_delivery_id: delivery_id)
        .select(:purchase_account_code)
        .single_value
    end

    def purchase_invoice_cost(cost_id)
      PackMaterialApp::ReplenishRepo.new.find_mr_purchase_invoice_cost(cost_id)
    end

    def products_for_delivery(delivery_id)
      items = DB[:mr_delivery_items].where(mr_delivery_id: delivery_id).all

      line_items = []
      items.each do |item|
        product = mr_delivery_item_with_product(item[:id])
        line_item = {
          product_number: formatted_number(product.product_variant_number),
          product_description: product.product_variant_code,
          unit_price: product.invoiced_unit_price,
          quantity: product.quantity_received,
          purchase_order_number: purchase_order_number(product.mr_purchase_order_item_id)
        }
        line_items << line_item
      end
      line_items
    end

    def formatted_number(pv_number)
      ConfigRepo.new.format_product_variant_number(pv_number)
    end

    def purchase_order_number(mr_purchase_order_item_id)
      DB[:mr_purchase_orders].where(
        id: DB[:mr_purchase_order_items].where(
          id: mr_purchase_order_item_id
        ).get(:mr_purchase_order_id)
      ).get(:purchase_order_number)
    end

    def mr_delivery_item_with_product(mr_delivery_item_id)
      find_with_association(:mr_delivery_items,
                            mr_delivery_item_id,
                            parent_tables: [{ parent_table: :material_resource_product_variants,
                                              foreign_key: :mr_product_variant_id,
                                              flatten_columns: { product_variant_number: :product_variant_number, product_variant_code: :product_variant_code } }],
                            wrapper: MrDeliveryItem)
    end
  end
end
