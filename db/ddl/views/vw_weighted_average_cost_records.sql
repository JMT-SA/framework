DROP VIEW vw_weighted_average_cost_records;

CREATE VIEW vw_weighted_average_cost_records as
SELECT
    ROW_NUMBER() OVER () AS id,
    the_rest.mr_product_variant_id,
    mrpv.product_variant_code,
    the_rest.sku_number,
    the_rest.sku_id,
    the_rest.applicable_id,
    the_rest.quantity,
    the_rest.price,
    the_rest.record_type,
    the_rest.factor,
    the_rest.actioned_at
FROM (
         SELECT
             skus.mr_product_variant_id,
             skus.sku_number::text,
             skus.id::text AS sku_id,
             mbsai.id AS applicable_id,
             (mbsai.actual_quantity - mbsai.system_quantity) AS quantity,
             mbsap.stock_adj_price AS price,
             'bulk stock adjustment item' AS record_type,
             1 AS factor,
             mbsa.signed_off_at AS actioned_at
         FROM
             mr_bulk_stock_adjustment_items mbsai
                 JOIN mr_skus skus ON mbsai.mr_sku_id = skus.id
                 JOIN mr_bulk_stock_adjustments mbsa ON mbsai.mr_bulk_stock_adjustment_id = mbsa.id
                 JOIN mr_bulk_stock_adjustment_prices mbsap ON mbsa.id = mbsap.mr_bulk_stock_adjustment_id
                 AND mbsap.mr_product_variant_id = skus.mr_product_variant_id
                 JOIN material_resource_product_variants mrpv ON skus.mr_product_variant_id = mrpv.id
         WHERE
                 mbsa.signed_off = TRUE
         UNION ALL
         SELECT
             coalesce(skus1.mr_product_variant_id, skus2.mr_product_variant_id) AS mr_product_variant_id,
             coalesce(skus1.sku_number, skus2.sku_number)::text AS sku_number,
             coalesce(skus1.id, skus2.id)::text AS sku_id,
             coalesce(item_batches.id, mr_delivery_items.id) AS applicable_id,
             coalesce(item_batches.quantity_received, mr_delivery_items.quantity_received) AS quantity,
             mr_delivery_items.invoiced_unit_price AS price,
             CASE WHEN item_batches.id NOTNULL THEN
                      'delivery batch item'
                  ELSE
                      'delivery item'
                 END AS record_type,
             1 AS factor,
             md.invoice_completed_at AS actioned_at
         FROM
             mr_delivery_items
                 LEFT JOIN mr_delivery_item_batches item_batches ON mr_delivery_items.id = item_batches.mr_delivery_item_id
                 LEFT JOIN mr_skus skus2 ON skus2.id = mr_delivery_items.mr_sku_id
                 LEFT JOIN mr_skus skus1 ON skus1.id = item_batches.mr_sku_id
                 LEFT JOIN mr_deliveries md ON mr_delivery_items.mr_delivery_id = md.id
         WHERE
                 md.invoice_completed = TRUE
         UNION ALL
         SELECT
             coalesce(skus4.mr_product_variant_id, skus3.mr_product_variant_id) AS mr_product_variant_id,
             coalesce(skus4.sku_number, skus3.sku_number)::text AS sku_number,
             coalesce(skus4.id, skus3.id)::text AS sku_id,
             grni.id AS applicable_id,
             grni.quantity_returned AS quantity,
             mdi.invoiced_unit_price AS price,
             CASE WHEN mdib.id NOTNULL THEN
                      'batch goods returned note item'
                  ELSE
                      'goods returned note item'
                 END AS record_type,
             (-1) AS factor,
             grn.invoice_completed_at AS actioned_at
         FROM
             mr_goods_returned_note_items grni
                 JOIN mr_goods_returned_notes grn ON grni.mr_goods_returned_note_id = grn.id
                 JOIN mr_delivery_items mdi ON grni.mr_delivery_item_id = mdi.id
                 LEFT JOIN mr_delivery_item_batches mdib ON mdib.id = grni.mr_delivery_item_batch_id
                 LEFT JOIN mr_skus skus3 ON mdi.mr_sku_id = skus3.id
                 LEFT JOIN mr_skus skus4 ON mdib.mr_sku_id = skus4.id
         WHERE
             grn.invoice_completed
         UNION ALL
         SELECT
             soi.mr_product_variant_id,
             (
                 SELECT
                     mr_skus.sku_number
                 FROM
                     mr_skus
                 WHERE
                         mr_skus.mr_product_variant_id = soi.mr_product_variant_id
                 LIMIT 1)::text AS sku_number,
             (
                 SELECT
                     mr_skus.id
                 FROM
                     mr_skus
                 WHERE
                         mr_skus.mr_product_variant_id = soi.mr_product_variant_id
                 LIMIT 1)::text AS sku_id,
             soi.id AS applicable_id,
             soi.quantity_required AS quantity,
             soi.unit_price AS price,
             'sales order item' AS record_type,
             (-1) AS factor,
             so.invoice_completed_at AS actioned_at
         FROM
             mr_sales_order_items soi
                 JOIN mr_sales_orders so ON soi.mr_sales_order_id = so.id
         WHERE
             so.integration_completed
         UNION ALL
         SELECT
             soi.mr_product_variant_id,
             (
                 SELECT
                     mr_skus.sku_number
                 FROM
                     mr_skus
                 WHERE
                         mr_skus.mr_product_variant_id = soi.mr_product_variant_id
                 LIMIT 1)::text AS sku_number,
             (
                 SELECT
                     mr_skus.id
                 FROM
                     mr_skus
                 WHERE
                         mr_skus.mr_product_variant_id = soi.mr_product_variant_id
                 LIMIT 1)::text AS sku_id,
             sri.id AS applicable_id,
             sri.quantity_returned AS quantity,
             soi.unit_price AS price,
             'sales return item' AS record_type,
             1 AS factor,
             sr.completed_at AS actioned_at
         FROM
             mr_sales_return_items sri
                 JOIN mr_sales_returns sr ON sri.mr_sales_return_id = sr.id
                 JOIN mr_sales_order_items soi ON sri.mr_sales_order_item_id = sr.id
         WHERE
             sr.completed) the_rest
LEFT JOIN material_resource_product_variants mrpv on mrpv.id = the_rest.mr_product_variant_id
ORDER BY actioned_at desc;