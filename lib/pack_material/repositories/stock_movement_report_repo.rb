# frozen_string_literal: true

module PackMaterialApp
  class StockMovementReportRepo < BaseRepo
    def stock_movement_report(start_date, end_date)
      DB["select mrpv.id,
                 mrpv.product_variant_code,
                 (select sje.opening_balance
                  from stock_journal_entries sje
                  where sje.opening_balance_at < ('#{start_date}')::date and mrpv.id = sje.mr_product_variant_id
                  order by opening_balance_at desc limit 1),
                 fn_stock_quantity_received(mrpv.id, ('#{start_date}')::date, ('#{end_date}')::date) as quantity_received,
                 fn_stock_quantity_returned(mrpv.id, ('#{start_date}')::date, ('#{end_date}')::date) as quantity_returned,
                 fn_stock_quantity_sold(mrpv.id, ('#{start_date}')::date, ('#{end_date}')::date) as quantity_sold,
                 (select (sje.opening_balance + fn_stock_total_at(mrpv.id,('#{start_date}')::date,('#{end_date}')::date))
                  from stock_journal_entries sje
                  where sje.opening_balance_at < ('#{start_date}')::date and mrpv.id = sje.mr_product_variant_id
                  order by opening_balance_at desc limit 1) as closing_balance
                 from material_resource_product_variants mrpv"].all
    end

    def validate_stock_movement_report_date_params(attrs)
      start_date = Date.new(attrs[:start_year].to_i, attrs[:start_month].to_i, 1)
      return validation_failed_response(OpenStruct.new(messages: { base: ['Start Date must be after Stock Take On Date.'] })) if start_date <= stock_take_on_date

      end_date = attrs[:end_date]
      return validation_failed_response(OpenStruct.new(messages: { base: ['End Date must be after Start Date.'] })) if end_date <= start_date

      success_response('Dates are valid.', { start_date: start_date, end_date: end_date })
    end

    def stock_take_on_date
      Date.parse(AppConst::STOCK_TAKE_ON_DATE)
    end

    def stock_movement_report_records(start_date, end_date)
      DB["select ROW_NUMBER() OVER() as id,
               skus.mr_product_variant_id,
        --        skus.sku_number,
        --        skus.id as sku_id,
               mbsai.id as applicable_id,
               (mbsai.actual_quantity - mbsai.system_quantity) as quantity,
               'bulk stock adjustment item' as type,
               mbsa.signed_off_at as actioned_at
        from mr_bulk_stock_adjustment_items mbsai
                 join mr_skus skus on mbsai.mr_sku_id = skus.id
                 join mr_bulk_stock_adjustments mbsa on mbsai.mr_bulk_stock_adjustment_id = mbsa.id
                 join mr_bulk_stock_adjustment_prices mbsap on mbsa.id = mbsap.mr_bulk_stock_adjustment_id and mbsap.mr_product_variant_id = skus.mr_product_variant_id
                 join material_resource_product_variants mrpv on skus.mr_product_variant_id = mrpv.id
        where mbsa.signed_off = true
          and mbsa.signed_off_at < ('#{end_date}')::date
          and mbsa.signed_off_at >= ('#{start_date}')::date
        union all
        select ROW_NUMBER() OVER() as id,
               coalesce(skus1.mr_product_variant_id, skus2.mr_product_variant_id) as mr_product_variant_id,
        --        coalesce(skus1.sku_number, skus2.sku_number) as sku_number,
        --        coalesce(skus1.id, skus2.id) as sku_id,
               coalesce(item_batches.id, mr_delivery_items.id) as applicable_id,
               coalesce(item_batches.quantity_received, mr_delivery_items.quantity_received) as quantity,
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
          and md.invoice_completed_at < ('#{end_date}')::date
          and md.invoice_completed_at >= ('#{start_date}')::date
        union all
        select ROW_NUMBER() OVER() as id,
               coalesce(skus4.mr_product_variant_id, skus3.mr_product_variant_id) as mr_product_variant_id,
        --        coalesce(skus4.sku_number, skus3.sku_number) as sku_number,
        --        coalesce(skus4.id, skus3.id) as sku_id,
               grni.id as applicable_id,
               grni.quantity_returned as quantity,
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
          and grn.invoice_completed_at < ('#{end_date}')::date
          and grn.invoice_completed_at >= ('#{start_date}')::date
        union all
        select ROW_NUMBER() OVER() as id,
               soi.mr_product_variant_id,
        --        can't select sku number or id here
               soi.id as applicable_id,
               soi.quantity_required as quantity,
               'sales order item' as type,
               so.invoice_completed_at as actioned_at
        from mr_sales_order_items soi
                 join mr_sales_orders so on soi.mr_sales_order_id = so.id
        where so.integration_completed
          and so.invoice_completed_at < ('#{end_date}')::date
          and so.invoice_completed_at >= ('#{start_date}')::date
        order by actioned_at asc;"].all
    end
  end
end
