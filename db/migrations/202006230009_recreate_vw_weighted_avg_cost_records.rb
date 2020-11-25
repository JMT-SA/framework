Sequel.migration do
  up do
    drop_view(:vw_weighted_average_cost_records)

    create_view(:vw_weighted_average_cost_records,
      "SELECT skus.mr_product_variant_id,
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
      OWNER TO postgres;")
  end

  down do
    drop_view(:vw_weighted_average_cost_records)
    create_view(:vw_weighted_average_cost_records,
                "select skus.mr_product_variant_id,
                       skus.sku_number,
                       skus.id as sku_id,
                       mbsai.id,
                       (mbsai.actual_quantity - mbsai.system_quantity) as quantity,
                       'bsa_item' as type,
                       mbsap.stock_adj_price as price,
                       mbsai.created_at
                from mr_bulk_stock_adjustment_items mbsai
                         join mr_skus skus on mbsai.mr_sku_id = skus.id
                         join mr_bulk_stock_adjustments mbsa on mbsai.mr_bulk_stock_adjustment_id = mbsa.id
                         join mr_bulk_stock_adjustment_prices mbsap on mbsa.id = mbsap.mr_bulk_stock_adjustment_id and mbsap.mr_product_variant_id = skus.mr_product_variant_id
                         join material_resource_product_variants mrpv on skus.mr_product_variant_id = mrpv.id
                where mbsa.signed_off = true
                union all
                select coalesce(skus1.mr_product_variant_id, skus2.mr_product_variant_id) as mr_product_variant_id,
                       coalesce(skus1.sku_number, skus2.sku_number) as sku_number,
                       coalesce(skus1.id, skus2.id) as sku_id,
                       coalesce(item_batches.id, mr_delivery_items.id) as id,
                       coalesce(item_batches.quantity_received, mr_delivery_items.quantity_received) as quantity,
                       case
                           when item_batches.id notnull then 'item_batch'
                           else 'item'
                           end as type,
                       mr_delivery_items.invoiced_unit_price as price,
                       mr_delivery_items.created_at
                from mr_delivery_items
                         left join mr_delivery_item_batches item_batches on mr_delivery_items.id = item_batches.mr_delivery_item_id
                         left join mr_skus skus2 on skus2.id = mr_delivery_items.mr_sku_id
                         left join mr_skus skus1 on skus1.id = item_batches.mr_sku_id
                         left join mr_deliveries md on mr_delivery_items.mr_delivery_id = md.id
                where md.invoice_completed = true
                union all
                select coalesce(skus4.mr_product_variant_id, skus3.mr_product_variant_id) as mr_product_variant_id,
                       coalesce(skus4.sku_number, skus3.sku_number) as sku_number,
                       coalesce(skus4.id, skus3.id) as sku_id,
                       grni.id,
                       grni.quantity_returned as quantity,
                       case
                           when mdib.id notnull then 'batch_grni'
                           else 'item_grni'
                           end as type,
                       mdi.invoiced_unit_price as price,
                       mdi.created_at
                from mr_goods_returned_note_items grni
                     join mr_delivery_items mdi on grni.mr_delivery_item_id = mdi.id
                     left join mr_delivery_item_batches mdib on mdib.id = grni.mr_delivery_item_batch_id
                     left join mr_skus skus3 on mdi.mr_sku_id = skus3.id
                     left join mr_skus skus4 on mdib.mr_sku_id = skus4.id
                order by created_at asc;"
    )
  end
end
