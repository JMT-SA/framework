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
      find_with_association(:mr_sales_return_items, id,
                            wrapper: MrSalesReturnItemFlat,
                            parent_tables: [{ parent_table: :mr_sales_returns, columns: %i[sales_return_number created_by remarks], foreign_key: :mr_sales_return_id, flatten_columns: { sales_return_number: :sales_return_number, created_by: :created_by } },
                                            { parent_table: :mr_sales_order_items, columns: %i[quantity_required unit_price], foreign_key: :mr_sales_order_item_id, flatten_columns: { quantity_required: :quantity_required, unit_price: :unit_price } },
                                            { parent_table: :material_resource_product_variants, columns: %i[product_variant_code], foreign_key: :mr_product_variant_id, flatten_columns: { product_variant_code: :product_variant_code } }],
                            lookup_functions: [
                              { function: :fn_current_status, args: ['mr_sales_return_items', :id], col_name: :status }
                            ])
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

    def sales_return_costs(mr_sales_return_id)
      DB[:sales_return_costs]
        .join(:mr_cost_types, id: :mr_cost_type_id)
        .where(mr_sales_return_id: mr_sales_return_id)
        .select(:cost_type_code, :amount, :account_code).all
    end

    def sales_returns_item_options(sales_return_id)  # rubocop:disable Metrics/AbcSize
      DB[:mr_sales_order_items]
        .join(:material_resource_product_variants, id: :mr_product_variant_id)
        .where(Sequel[:mr_sales_order_items][:mr_sales_order_id] => DB[:mr_sales_returns].where(id: sales_return_id).get(:mr_sales_order_id))
        .distinct(:product_variant_code)
        .select(
          Sequel[:mr_sales_order_items][:id],
          :product_variant_code
        )
        .order(:product_variant_code)
        .map { |r| [r[:product_variant_code], r[:id]] }
    end

    def validate_sales_return_quantity_amount(sales_return_item_id, attrs)
      new_qty = BigDecimal(attrs[:column_value]) || attrs[:quantity_returned]
      record = sales_order_record(sales_return_item_id)

      sales_order_qty = (record.get(:quantity_required) || AppConst::BIG_ZERO)
      return failed_response("Quantity available: #{UtilityFunctions.delimited_number(sales_order_qty)}") unless new_qty <= sales_order_qty

      success_response('valid quantity')
    end

    def sales_order_record(sales_return_item_id)
      DB[:mr_sales_order_items]
        .join(:mr_sales_return_items, mr_sales_order_item_id: :id)
        .where(Sequel[:mr_sales_return_items][:id] => sales_return_item_id)
    end

    def inline_update_sales_return_items(id, attrs)
      update(:mr_sales_return_items, id, "#{attrs[:column_name]}": attrs[:column_value])
    end
  end
end
