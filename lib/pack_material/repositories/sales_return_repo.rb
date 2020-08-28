# frozen_string_literal: true

module PackMaterialApp
  class SalesReturnRepo < BaseRepo # rubocop:disable Metrics/ClassLength
    build_for_select :mr_sales_returns,
                     label: :created_by,
                     value: :id,
                     no_active_check: true,
                     order_by: :created_by
    build_for_select :mr_sales_return_items,
                     label: :remarks,
                     value: :id,
                     no_active_check: true,
                     order_by: :remarks
    build_for_select :sales_return_costs,
                     label: :id,
                     value: :id,
                     no_active_check: true,
                     order_by: :id

    crud_calls_for :mr_sales_returns, name: :mr_sales_return, wrapper: MrSalesReturn
    crud_calls_for :mr_sales_return_items, name: :mr_sales_return_item, wrapper: MrSalesReturnItem
    crud_calls_for :sales_return_costs, name: :sales_return_cost, wrapper: SalesReturnCost

    def find_mr_sales_return(id)
      find_with_association(:mr_sales_returns, id,
                            wrapper: MrSalesReturnFlat,
                            parent_tables: [
                              { parent_table: :mr_sales_orders,
                                columns: %i[sales_order_number erp_customer_number],
                                flatten_columns: { sales_order_number: :sales_order_number,
                                                   erp_customer_number: :erp_customer_number } }
                            ],
                            lookup_functions: [
                              { function: :fn_current_status, args: ['mr_sales_returns', :id], col_name: :status }
                            ])
    end

    def find_mr_sales_return_item(id)
      query = <<~SQL
        SELECT mr_sales_return_items.id, mr_sales_return_items.mr_sales_return_id, mr_sales_return_items.mr_sales_order_item_id,
               mr_sales_returns.sales_return_number, mr_sales_return_items.remarks, mr_sales_return_items.quantity_returned,
               mr_sales_order_items.quantity_required, mr_sales_order_items.unit_price, material_resource_product_variants.product_variant_code,
               mr_sales_return_items.created_at, mr_sales_return_items.updated_at, mr_sales_returns.created_by,
               fn_current_status('mr_sales_return_items', mr_sales_return_items.id) AS status
        FROM mr_sales_returns
        JOIN mr_sales_return_items ON mr_sales_returns.id = mr_sales_return_items.mr_sales_return_id
        JOIN mr_sales_order_items ON mr_sales_order_items.id = mr_sales_return_items.mr_sales_order_item_id
        JOIN material_resource_product_variants ON mr_sales_order_items.mr_product_variant_id = material_resource_product_variants.id
        WHERE mr_sales_return_items.id = ?
      SQL
      hash = DB[query, id].first
      return nil if hash.nil?

      MrSalesReturnItemFlat.new(hash)
    end

    def find_sales_return_cost(id)
      find_with_association(:sales_return_costs, id,
                            wrapper: SalesReturnCostFlat,
                            parent_tables: [
                              {
                                parent_table: :mr_cost_types,
                                columns: [:cost_type_code],
                                flatten_columns: { cost_type_code: :cost_type_code }
                              }
                            ])
    end

    def delete_mr_sales_return(id)
      DB[:sales_return_costs].where(mr_sales_return_id: id).delete
      DB[:mr_sales_return_items].where(mr_sales_return_id: id).delete
      DB[:mr_sales_returns].where(id: id).delete
      { success: true }
    end

    def sales_return_sub_totals(id, opts = {})
      subtotal = sales_return_total_items(id)
      costs = sales_return_total_costs(id)
      vat = sales_return_total_vat(id, subtotal)
      {
        subtotal: UtilityFunctions.delimited_number(subtotal, opts),
        costs: UtilityFunctions.delimited_number(costs, opts),
        vat: UtilityFunctions.delimited_number(vat, opts),
        total: UtilityFunctions.delimited_number(subtotal + costs + vat, opts)
      }
    end

    def sales_return_total_items(id)
      DB['SELECT SUM(mr_sales_return_items.quantity_returned * mr_sales_order_items.unit_price) AS total
          FROM mr_sales_return_items
          JOIN mr_sales_order_items on mr_sales_order_items.id = mr_sales_return_items.mr_sales_order_item_id
          WHERE mr_sales_return_items.mr_sales_return_id = ?', id].single_value || AppConst::BIG_ZERO
    end

    def sales_return_total_costs(id)
      DB[:sales_return_costs].where(mr_sales_return_id: id).sum(:amount) || AppConst::BIG_ZERO
    end

    def sales_return_total_vat(id, subtotal)
      return AppConst::BIG_ZERO if subtotal.zero?

      factor = DB['SELECT mr_vat_types.percentage_applicable/100
                   FROM mr_sales_returns
                   JOIN mr_sales_return_items ON mr_sales_returns.id = mr_sales_return_items.mr_sales_return_id
                   JOIN mr_sales_order_items ON mr_sales_return_items.mr_sales_order_item_id = mr_sales_order_items.id
                   JOIN mr_sales_orders ON mr_sales_order_items.mr_sales_order_id = mr_sales_orders.id
                   JOIN mr_vat_types ON mr_sales_orders.vat_type_id = mr_vat_types.id
                   WHERE mr_sales_returns.id = ?', id].single_value || AppConst::BIG_ZERO

      subtotal * factor
    end

    def sales_return_costs(sales_return_id)
      DB[:sales_return_costs]
        .join(:mr_cost_types, id: :mr_cost_type_id)
        .where(mr_sales_return_id: sales_return_id)
        .select(:cost_type_code, :amount, :account_code).all
    end

    def sales_returns_item_options(sales_return_id)  # rubocop:disable Metrics/AbcSize
      DB[:mr_sales_order_items]
        .join(:material_resource_product_variants, id: :mr_product_variant_id)
        .where(Sequel[:mr_sales_order_items][:mr_sales_order_id] => DB[:mr_sales_returns].where(id: sales_return_id).get(:mr_sales_order_id))
        .where(returned: false)
        .distinct(:product_variant_code)
        .select(
          Sequel[:mr_sales_order_items][:id],
          :product_variant_code
        )
        .order(:product_variant_code)
        .map { |r| [r[:product_variant_code], r[:id]] }
    end

    def validate_sales_return_quantity_amount(sales_return_item_id, attrs)  # rubocop:disable Metrics/AbcSize
      new_qty = BigDecimal(attrs[:column_value]) || attrs[:quantity_returned]
      record = sales_order_item_record(sales_return_item_id)
      return failed_response('Item has already been returned in full') if record.get(:returned)

      prev_returned_qty = item_prev_returned_quantity(record.get(:mr_sales_order_item_id), record.get(:mr_sales_return_id))
      available_qty = (record.get(:quantity_required) || AppConst::BIG_ZERO) - prev_returned_qty
      return failed_response("Quantity available: #{UtilityFunctions.delimited_number(available_qty)}") unless new_qty <= available_qty

      success_response('valid quantity')
    end

    def item_prev_returned_quantity(sales_order_item_id, sales_return_id)
      query = <<~SQL
        SELECT COALESCE(SUM(COALESCE(quantity_returned, 0)), 0) as total_quantity_returned
        FROM mr_sales_return_items
        WHERE mr_sales_return_items.mr_sales_order_item_id = #{sales_order_item_id}
        AND mr_sales_return_items.mr_sales_return_id != #{sales_return_id}
      SQL
      DB[query].first[:total_quantity_returned]
    end

    def sales_order_item_record(sales_return_item_id)
      DB[:mr_sales_order_items]
        .join(:mr_sales_return_items, mr_sales_order_item_id: :id)
        .where(Sequel[:mr_sales_return_items][:id] => sales_return_item_id)
    end

    def inline_update_sales_return_items(id, attrs)
      update(:mr_sales_return_items, id, "#{attrs[:column_name]}": attrs[:column_value])
    end

    def update_sales_return(id, attrs)
      update(:mr_sales_returns, id, attrs)
    end

    def sales_return_sku_ids(sales_return_id)
      DB[:mr_skus]
        .join(:mr_sales_order_items, id: :mr_product_variant_id)
        .join(:mr_sales_return_items, id: :mr_sales_order_item_id)
        .where(mr_sales_return_id: sales_return_id)
        .select_map(Sequel[:mr_sales_return_items][:id]).uniq
    end

    def sales_return_stock_items(sales_return_id)
      stock_items = []
      items = DB[:mr_sales_return_items].where(mr_sales_return_id: sales_return_id).all
      items.each do |item|
        stock_items << { sku_id: sku_id_for_sales_return_item(item[:id]),
                         qty: item[:quantity_returned] }
      end
      stock_items
    end

    def sku_id_for_sales_return_item(sales_return_item_id)
      DB[:mr_skus]
        .where(mr_product_variant_id: DB[:mr_sales_order_items]
                                          .join(:mr_sales_return_items, mr_sales_order_item_id: :id)
                                          .where(Sequel[:mr_sales_return_items][:id] => sales_return_item_id)
                                          .get(:mr_product_variant_id))
        .get(:id)
    end

    def sales_return_order(sales_return_id)
      DB[:mr_sales_returns]
        .where(id: sales_return_id)
        .get(:mr_sales_order_id)
    end

    def sales_return_order_item(sales_return_item_id)
      DB[:mr_sales_return_items]
        .where(id: sales_return_item_id)
        .get(:mr_sales_order_item_id)
    end

    def sales_return_number(sales_return_id)
      DB[:mr_sales_returns]
        .where(id: sales_return_id)
        .get(:sales_return_number)
    end

    def sales_return_item_return_id(sales_return_item_id)
      DB[:mr_sales_return_items]
        .where(id: sales_return_item_id)
        .get(:mr_sales_return_id)
    end

    def sales_return_item_quantity_returned(sales_return_item_id)
      DB[:mr_sales_return_items]
        .where(id: sales_return_item_id)
        .get(:quantity_returned)
    end

    def sales_return_item_sku_info(sales_return_item_id)  # rubocop:disable Metrics/AbcSize
      sales_return_id = sales_return_item_return_id(sales_return_item_id)

      sku_id = sku_id_for_sales_return_item(sales_return_item_id)
      sku = DB[:mr_skus].where(id: sku_id).first
      pv_code, pv_number = DB[:material_resource_product_variants]
                           .where(id: sku[:mr_product_variant_id])
                           .get(%i[product_variant_code product_variant_number])
      pv_number = ConfigRepo.new.format_product_variant_number(pv_number)
      batch_number = DB[:mr_internal_batch_numbers].where(id: sku[:mr_internal_batch_number_id]).get(:batch_number)
      no_of_prints = sales_return_item_quantity_returned(sales_return_item_id)
      no_of_prints = 1 if no_of_prints.zero? || no_of_prints.negative?
      {
        mr_sales_return_item_id: sales_return_item_id,
        sales_return_number: sales_return_number(sales_return_id),
        sku_id: sku_id,
        sku_number: sku[:sku_number],
        product_variant_code: pv_code,
        product_variant_number: pv_number,
        batch_number: batch_number,
        no_of_prints: no_of_prints.to_i
      }
    end

    def sales_order_partially_returned?(sales_order_id)
      DB[:mr_sales_order_items]
        .where(mr_sales_order_id: sales_order_id)
        .map(:returned).uniq.include?(false)
    end

    def sales_order_item_fully_returned?(sales_return_item_id)
      record = sales_order_item_record(sales_return_item_id)
      quantity_returned = DB[:mr_sales_return_items]
                          .where(mr_sales_order_item_id: record.get(:mr_sales_order_item_id))
                          .sum(:quantity_returned)

      available_qty = record.get(:quantity_required) - quantity_returned
      available_qty.zero?
    end

    def products_for_sales_return(sales_return_id)
      DB[:mr_sales_return_items]
        .join(:mr_sales_order_items, id: :mr_sales_order_item_id)
        .join(:material_resource_product_variants, id: :mr_product_variant_id)
        .where(mr_sales_return_id: sales_return_id)
        .select(:quantity_returned,
                :unit_price,
                :product_variant_code,
                :weighted_average_cost,
                (Sequel[:mr_sales_return_items][:quantity_returned] * Sequel[:mr_sales_order_items][:unit_price]).as(:line_total))
        .all
    end

    def complete_sales_return(user_name, id, _attrs)
      attrs = { integration_error: false,
                completed: true,
                completed_at: DateTime.now,
                completed_by: user_name }
      update(:mr_sales_returns, id, attrs)
    end

    def update_sales_return_order_status(sales_return_id)
      sales_order_id = sales_return_order(sales_return_id)
      sales_return_item_ids = DB[:mr_sales_return_items].where(mr_sales_return_id: sales_return_id).map(:id)
      sales_return_item_ids.each do |item_id|
        item_fully_returned = sales_order_item_fully_returned?(item_id)
        update(:mr_sales_order_items, sales_return_order_item(item_id), { returned: item_fully_returned })
      end
      order_partially_returned = sales_order_partially_returned?(sales_order_id)
      update(:mr_sales_orders, sales_order_id, { returned: true }) unless order_partially_returned
    end
  end
end
