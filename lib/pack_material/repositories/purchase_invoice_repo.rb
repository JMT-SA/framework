# frozen_string_literal: true

module PackMaterialApp
  class PurchaseInvoiceRepo < BaseRepo # rubocop:disable Metrics/ClassLength
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
        .join(:account_codes, id: :account_code_id)
        .where(mr_delivery_id: delivery_id)
        .select(:account_code)
        .single_value
    end

    def purchase_invoice_cost(cost_id)
      PackMaterialApp::ReplenishRepo.new.find_mr_purchase_invoice_cost(cost_id)
    end

    def products_for_delivery(delivery_id)
      items = DB[:mr_delivery_items].where(mr_delivery_id: delivery_id).all
      products_for_items(items)
    end

    def products_for_goods_returned_note(grn_id)
      grn_items_dataset = DB[:mr_goods_returned_note_items].where(mr_goods_returned_note_id: grn_id)
      item_ids = grn_items_dataset.map { |r| r[:mr_delivery_item_id] }.uniq
      items = DB[:mr_delivery_items].where(id: item_ids).all
      line_items = products_for_items(items)

      line_items.each do |line_item|
        line_item[:quantity] = grn_items_dataset.where(mr_delivery_item_id: line_item[:item_id]).sum(:quantity_returned)
      end
    end

    def products_for_items(items)
      line_items = []
      items.each do |item|
        product = mr_delivery_item_with_product(item[:id])
        line_item = {
          item_id: item[:id],
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

    def cn_sub_totals(id, opts = {})
      # def cn_sub_totals(grn_id, delimiter: '', no_decimals: 5)
      subtotal = cn_total_items(id)
      vat = cn_total_vat(id, subtotal)
      {
        subtotal: UtilityFunctions.delimited_number(subtotal, opts),
        vat: UtilityFunctions.delimited_number(vat, opts),
        total: UtilityFunctions.delimited_number(subtotal + vat, opts)
      }
    end

    def cn_total_items(id)
      DB['SELECT SUM(mr_goods_returned_note_items.quantity_returned * mr_delivery_items.invoiced_unit_price) AS total
          FROM mr_goods_returned_note_items
          JOIN mr_delivery_items on mr_delivery_items.id = mr_goods_returned_note_items.mr_delivery_item_id
          WHERE mr_goods_returned_note_items.mr_goods_returned_note_id = ?', id].single_value || AppConst::BIG_ZERO
    end

    def cn_total_vat(id, subtotal)
      return AppConst::BIG_ZERO if subtotal.zero?

      factor = DB['SELECT mvt.percentage_applicable/100
        FROM mr_goods_returned_notes
        JOIN mr_goods_returned_note_items mgrni on mr_goods_returned_notes.id = mgrni.mr_goods_returned_note_id
        JOIN mr_delivery_items mdi on mgrni.mr_delivery_item_id = mdi.id
        JOIN mr_purchase_order_items mpoi on mdi.mr_purchase_order_item_id = mpoi.id
        JOIN mr_purchase_orders mpo on mpoi.mr_purchase_order_id = mpo.id
        JOIN mr_vat_types mvt on mpo.mr_vat_type_id = mvt.id
        WHERE mr_goods_returned_notes.id = ?', id].single_value || AppConst::BIG_ZERO

      subtotal * factor
    end
  end
end
