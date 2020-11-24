create or replace function fn_stock_quantity_sales_returned(in_id integer, start_date date, end_date date) returns numeric
    language sql
as
$$
select coalesce(sum(sri.quantity_returned), 0) as quantity_sales_returned
from mr_sales_return_items sri
join mr_sales_returns sr on sri.mr_sales_return_id = sr.id
join mr_sales_order_items soi on sri.mr_sales_order_item_id = soi.id
join mr_sales_orders so on soi.mr_sales_order_id = so.id
where soi.mr_product_variant_id = in_id
  and sr.completed_at < end_date
  and sr.completed_at >= start_date
$$;

alter function fn_stock_quantity_sales_returned(integer, date, date) owner to postgres;
