# frozen_string_literal: true

module PackMaterialApp
  class WaCostRepo < BaseRepo # rubocop:disable Metrics/ClassLength
    def calculate_wa_costs
      pv_ids = DB[:material_resource_product_variants].select_map(:id)
      pv_ids.each do |pv_id|
        cost = wa_cost(pv_id) || BigDecimal('0')
        DB[:material_resource_product_variants].where(id: pv_id).update(weighted_average_cost: cost)
      end
    end

    def update_wa_cost(mrpv_id)
      cost = wa_cost(mrpv_id) || BigDecimal('0')
      DB[:material_resource_product_variants].where(id: mrpv_id).update(weighted_average_cost: cost)
    end

    def wa_cost_for_sku_id(sku_id)
      pv_id = DB[:mr_skus].where(id: sku_id).get(:mr_product_variant_id)
      wa_cost(pv_id)
    end

    def wa_cost_records_for_variant(mrpv_id)
      weighted_average_cost_records.select { |r| r[:mr_product_variant_id] == mrpv_id }
    end

    def wa_cost(mrpv_id) # rubocop:disable Metrics/AbcSize
      total_qty = total_quantity(mrpv_id)
      return nil unless total_qty&.positive?

      rest = total_qty
      total_amt = 0
      records = wa_cost_records_for_variant(mrpv_id)
      records.each do |r|
        qty = r[:quantity]
        rest -= qty.abs
        next if r[:price].nil?

        amt = (rest.positive? || rest.zero? ? r[:quantity] : rest.abs) * r[:price]
        total_amt += amt
        break if rest.negative?
      end
      total_amt / total_qty
    end

    def total_quantity(mrpv_id)
      DB[:mr_sku_locations].where(mr_sku_id: DB[:mr_skus].where(mr_product_variant_id: mrpv_id).select_map(:id)).sum(:quantity)
    end

    def weighted_average_cost_records
      DB[:vw_weighted_average_cost_records].all
    end

    # @return [Array] Query returning wa_cost records including Sales Order Items
    def wa_cost_records
      DB["select ROW_NUMBER() OVER() as id,
                 skus.mr_product_variant_id,
                        skus.sku_number::text,
                        skus.id::text as sku_id,
                 mbsai.id as applicable_id,
                 (mbsai.actual_quantity - mbsai.system_quantity) as quantity,
                 mbsap.stock_adj_price as price,
                 'bulk stock adjustment item' as type,
                 mbsa.signed_off_at as actioned_at
        from mr_bulk_stock_adjustment_items mbsai
                 join mr_skus skus on mbsai.mr_sku_id = skus.id
                 join mr_bulk_stock_adjustments mbsa on mbsai.mr_bulk_stock_adjustment_id = mbsa.id
                 join mr_bulk_stock_adjustment_prices mbsap on mbsa.id = mbsap.mr_bulk_stock_adjustment_id and mbsap.mr_product_variant_id = skus.mr_product_variant_id
                 join material_resource_product_variants mrpv on skus.mr_product_variant_id = mrpv.id
        where mbsa.signed_off = true
        --   and mbsa.signed_off_at < ('#{end_date}')::date
        --   and mbsa.signed_off_at >= ('#{start_date}')::date
        union all
        select ROW_NUMBER() OVER() as id,
               coalesce(skus1.mr_product_variant_id, skus2.mr_product_variant_id) as mr_product_variant_id,
                      coalesce(skus1.sku_number, skus2.sku_number)::text as sku_number,
                      coalesce(skus1.id, skus2.id)::text as sku_id,
               coalesce(item_batches.id, mr_delivery_items.id) as applicable_id,
               coalesce(item_batches.quantity_received, mr_delivery_items.quantity_received) as quantity,
               mr_delivery_items.invoiced_unit_price as price,
               case
                   when item_batches.id notnull then 'delivery batch item'
                   else 'delivery item'
                   end as type,
               md.invoice_completed_at as actioned_at
        from mr_delivery_items
                 left join mr_delivery_item_batches item_batches on mr_delivery_items.id = item_batches.mr_delivery_item_id
                 left join mr_skus skus2 on skus2.id = mr_delivery_items.mr_sku_id
                 left join mr_skus skus1 on skus1.id = item_batches.mr_sku_id
                 left join mr_deliveries md on mr_delivery_items.mr_delivery_id = md.id
        where md.invoice_completed = true
        --   and md.invoice_completed_at < ('#{end_date}')::date
        --   and md.invoice_completed_at >= ('#{start_date}')::date
        union all
        select ROW_NUMBER() OVER() as id,
               coalesce(skus4.mr_product_variant_id, skus3.mr_product_variant_id) as mr_product_variant_id,
                      coalesce(skus4.sku_number, skus3.sku_number)::text as sku_number,
                      coalesce(skus4.id, skus3.id)::text as sku_id,
               grni.id as applicable_id,
               grni.quantity_returned as quantity,
               mdi.invoiced_unit_price as price,
               case
                   when mdib.id notnull then 'batch goods returned note item'
                   else 'goods returned note item'
                   end as type,
               grn.invoice_completed_at as actioned_at
        from mr_goods_returned_note_items grni
                 join mr_goods_returned_notes grn on grni.mr_goods_returned_note_id = grn.id
                 join mr_delivery_items mdi on grni.mr_delivery_item_id = mdi.id
                 left join mr_delivery_item_batches mdib on mdib.id = grni.mr_delivery_item_batch_id
                 left join mr_skus skus3 on mdi.mr_sku_id = skus3.id
                 left join mr_skus skus4 on mdib.mr_sku_id = skus4.id
        where grn.invoice_completed
        --   and grn.invoice_completed_at < ('#{end_date}')::date
        --   and grn.invoice_completed_at >= ('#{start_date}')::date
        union all
        select ROW_NUMBER() OVER() as id,
               soi.mr_product_variant_id,
               (select string_agg(mr_skus.sku_number::text, ';')
                from mr_skus
                where mr_skus.mr_product_variant_id = soi.mr_product_variant_id) as sku_number,
               (select string_agg(mr_skus.id::text, ';')
                from mr_skus
                where mr_skus.mr_product_variant_id = soi.mr_product_variant_id) as sku_id,
               --        can't select sku number or id here
               soi.id as applicable_id,
               soi.quantity_required as quantity,
               soi.unit_price as price,
               'sales order item' as type,
               so.invoice_completed_at as actioned_at
        from mr_sales_order_items soi
                 join mr_sales_orders so on soi.mr_sales_order_id = so.id
        where so.integration_completed
        --   and so.invoice_completed_at < ('#{end_date}')::date
        --   and so.invoice_completed_at >= ('#{start_date}')::date
        order by actioned_at asc;"].all
    end
  end
end
