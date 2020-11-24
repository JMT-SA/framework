create or replace function fn_stock_quantity_received(in_id integer, start_date date, end_date date) returns numeric
    language sql
as
$$
select coalesce(sum(coalesce(item_batches.quantity_received, mr_delivery_items.quantity_received)), 0) as quantity_received
from mr_delivery_items
         left join mr_delivery_item_batches item_batches on mr_delivery_items.id = item_batches.mr_delivery_item_id
         left join mr_skus skus2 on skus2.id = mr_delivery_items.mr_sku_id
         left join mr_skus skus1 on skus1.id = item_batches.mr_sku_id
         left join mr_deliveries md on mr_delivery_items.mr_delivery_id = md.id
where md.invoice_completed = true
  and (skus1.mr_product_variant_id = in_id or skus2.mr_product_variant_id = in_id)
  and md.invoice_completed_at < end_date
  and md.invoice_completed_at >= start_date
$$;

alter function fn_stock_quantity_received(integer, date, date) owner to postgres;
