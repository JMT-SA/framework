-- View: public.vw_weighted_average_cost_records

-- DROP VIEW public.vw_weighted_average_cost_records;

CREATE OR REPLACE VIEW public.vw_weighted_average_cost_records AS
SELECT skus.mr_product_variant_id,
       skus.sku_number,
       skus.id AS sku_id,
       mbsai.id,
       mbsai.actual_quantity - mbsai.system_quantity AS quantity,
       'bsa_item'::text AS type,
       mbsap.stock_adj_price AS price,
       mbsai.created_at
FROM mr_bulk_stock_adjustment_items mbsai
         JOIN mr_skus skus ON mbsai.mr_sku_id = skus.id
         JOIN mr_bulk_stock_adjustments mbsa ON mbsai.mr_bulk_stock_adjustment_id = mbsa.id
         JOIN mr_bulk_stock_adjustment_prices mbsap ON mbsa.id = mbsap.mr_bulk_stock_adjustment_id AND mbsap.mr_product_variant_id = skus.mr_product_variant_id
         JOIN material_resource_product_variants mrpv ON skus.mr_product_variant_id = mrpv.id
WHERE mbsa.signed_off = true
UNION ALL
SELECT COALESCE(skus1.mr_product_variant_id, skus2.mr_product_variant_id) AS mr_product_variant_id,
       COALESCE(skus1.sku_number, skus2.sku_number) AS sku_number,
       COALESCE(skus1.id, skus2.id) AS sku_id,
       COALESCE(item_batches.id, mr_delivery_items.id) AS id,
       COALESCE(item_batches.quantity_received, mr_delivery_items.quantity_received) AS quantity,
       CASE
           WHEN item_batches.id IS NOT NULL THEN 'item_batch'::text
           ELSE 'item'::text
           END AS type,
       mr_delivery_items.invoiced_unit_price AS price,
       mr_delivery_items.created_at
FROM mr_delivery_items
         LEFT JOIN mr_delivery_item_batches item_batches ON mr_delivery_items.id = item_batches.mr_delivery_item_id
         LEFT JOIN mr_skus skus2 ON skus2.id = mr_delivery_items.mr_sku_id
         LEFT JOIN mr_skus skus1 ON skus1.id = item_batches.mr_sku_id
         LEFT JOIN mr_deliveries md ON mr_delivery_items.mr_delivery_id = md.id
WHERE md.invoice_completed = true
UNION ALL
SELECT COALESCE(skus4.mr_product_variant_id, skus3.mr_product_variant_id) AS mr_product_variant_id,
       COALESCE(skus4.sku_number, skus3.sku_number) AS sku_number,
       COALESCE(skus4.id, skus3.id) AS sku_id,
       grni.id,
       grni.quantity_returned AS quantity,
       CASE
           WHEN mdib.id IS NOT NULL THEN 'batch_grni'::text
           ELSE 'item_grni'::text
           END AS type,
       mdi.invoiced_unit_price AS price,
       mdi.created_at
FROM mr_goods_returned_note_items grni
         JOIN mr_delivery_items mdi ON grni.mr_delivery_item_id = mdi.id
         LEFT JOIN mr_delivery_item_batches mdib ON mdib.id = grni.mr_delivery_item_batch_id
         LEFT JOIN mr_skus skus3 ON mdi.mr_sku_id = skus3.id
         LEFT JOIN mr_skus skus4 ON mdib.mr_sku_id = skus4.id
ORDER BY 8;

ALTER TABLE public.vw_weighted_average_cost_records
    OWNER TO postgres;
