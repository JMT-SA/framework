create or replace function fn_stock_total_at(in_id integer, start_date date, end_date date) returns numeric
    language plpgsql
as
$$
declare
    qty_bsa numeric;
    qty_rec numeric;
    qty_ret numeric;
    qty_sold numeric;
    qty_sales_ret numeric;
begin
    select fn_stock_quantity_bsa(in_id, start_date, end_date) into qty_bsa;
    select fn_stock_quantity_received(in_id, start_date, end_date) into qty_rec;
    select fn_stock_quantity_returned(in_id, start_date, end_date) into qty_ret;
    select fn_stock_quantity_sold(in_id, start_date, end_date) into qty_sold;
    select fn_stock_quantity_sales_returned(in_id, start_date, end_date) into qty_sales_ret;
    return (qty_bsa + qty_rec - qty_ret - qty_sold + qty_sales_ret);
end
$$;

alter function fn_stock_total_at(integer, date, date) owner to postgres;
