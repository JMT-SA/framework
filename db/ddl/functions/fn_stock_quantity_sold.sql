create or replace function fn_stock_quantity_sold(in_id integer, start_date date, end_date date) returns numeric
    language sql
as
$$
select coalesce(sum(soi.quantity_required), 0) as quantity_sold
from mr_sales_order_items soi
         join mr_sales_orders so on soi.mr_sales_order_id = so.id
where soi.mr_product_variant_id = in_id
  and so.invoice_completed_at < end_date
  and so.invoice_completed_at >= start_date
$$;

alter function fn_stock_quantity_sold(integer, date, date) owner to postgres;




