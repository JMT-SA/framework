create or replace function fn_stock_quantity_bsa(in_id integer, start_date date, end_date date) returns numeric
    language sql
as
$$
select coalesce(sum((mbsai.actual_quantity - mbsai.system_quantity)), 0) as quantity
from mr_bulk_stock_adjustment_items mbsai
         join mr_skus skus on mbsai.mr_sku_id = skus.id
         join mr_bulk_stock_adjustments mbsa on mbsai.mr_bulk_stock_adjustment_id = mbsa.id
         join mr_bulk_stock_adjustment_prices mbsap on mbsa.id = mbsap.mr_bulk_stock_adjustment_id and mbsap.mr_product_variant_id = skus.mr_product_variant_id
         join material_resource_product_variants mrpv on skus.mr_product_variant_id = mrpv.id
where mbsa.signed_off = true
  and mrpv.id = in_id
  and mbsa.signed_off_at < end_date
  and mbsa.signed_off_at >= start_date
$$;

alter function fn_stock_quantity_bsa(integer, date, date) owner to postgres;