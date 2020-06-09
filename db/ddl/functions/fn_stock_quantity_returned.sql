create or replace function fn_stock_quantity_returned(in_id integer, start_date date, end_date date) returns numeric
    language sql
as
$$
select coalesce(sum(grni.quantity_returned), 0) as quantity_returned
from mr_goods_returned_note_items grni
         join mr_delivery_items mdi on grni.mr_delivery_item_id = mdi.id
         join mr_deliveries md on mdi.mr_delivery_id = md.id
         left join mr_delivery_item_batches mdib on mdib.id = grni.mr_delivery_item_batch_id
         left join mr_skus skus3 on mdi.mr_sku_id = skus3.id
         left join mr_skus skus4 on mdib.mr_sku_id = skus4.id
where (skus4.mr_product_variant_id = in_id or skus3.mr_product_variant_id = in_id)
  and md.invoice_completed_at < end_date
  and md.invoice_completed_at >= start_date
$$;

alter function fn_stock_quantity_returned(integer, date, date) owner to postgres;

