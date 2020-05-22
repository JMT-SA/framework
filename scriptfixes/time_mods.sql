-- Drop view that return one or more of these columns to change:
DROP VIEW public.vw_active_users;
DROP VIEW public.vw_weighted_average_cost_records;

-- Alter all date times to include time zone:

ALTER TABLE audit.current_statuses
ALTER COLUMN action_tstamp_tx TYPE timestamp with time zone;

ALTER TABLE audit.logged_action_details
ALTER COLUMN action_tstamp_tx TYPE timestamp with time zone;

ALTER TABLE audit.status_logs
ALTER COLUMN action_tstamp_tx TYPE timestamp with time zone;


ALTER TABLE address_types
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE addresses
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE basic_pack_codes
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE commodities
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE commodity_groups
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE contact_method_types
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE contact_methods
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE cultivar_groups
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE cultivars
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE customers
ALTER COLUMN created_at TYPE timestamp without time zone,
ALTER COLUMN updated_at TYPE timestamp without time zone;

ALTER TABLE destination_cities
ALTER COLUMN updated_at TYPE timestamp with time zone,
ALTER COLUMN created_at TYPE timestamp with time zone;

ALTER TABLE destination_countries
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE destination_regions
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE fruit_actual_counts_for_packs
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE fruit_size_references
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE functional_areas
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE label_templates
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE labels
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE location_assignments
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE location_storage_definitions
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE location_storage_types
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE location_types
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE locations
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE marketing_varieties
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE master_lists
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE material_resource_domains
ALTER COLUMN created_at TYPE timestamp without time zone,
ALTER COLUMN updated_at TYPE timestamp without time zone;

ALTER TABLE material_resource_product_columns
ALTER COLUMN created_at TYPE timestamp without time zone,
ALTER COLUMN updated_at TYPE timestamp without time zone;

ALTER TABLE material_resource_product_variant_party_roles
ALTER COLUMN created_at TYPE timestamp without time zone,
ALTER COLUMN updated_at TYPE timestamp without time zone;

ALTER TABLE material_resource_product_variants
ALTER COLUMN created_at TYPE timestamp without time zone,
ALTER COLUMN updated_at TYPE timestamp without time zone;
ALTER COLUMN wa_cost_updated_at TYPE timestamp without time zone;

ALTER TABLE material_resource_sub_types
ALTER COLUMN created_at TYPE timestamp without time zone,
ALTER COLUMN updated_at TYPE timestamp without time zone;

ALTER TABLE material_resource_types
ALTER COLUMN created_at TYPE timestamp without time zone,
ALTER COLUMN updated_at TYPE timestamp without time zone;

ALTER TABLE mes_modules
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE message_bus
ALTER COLUMN added_at TYPE timestamp with time zone;

ALTER TABLE mr_bulk_stock_adjustment_items
ALTER COLUMN created_at TYPE timestamp without time zone,
ALTER COLUMN updated_at TYPE timestamp without time zone;

ALTER TABLE mr_bulk_stock_adjustments
ALTER COLUMN created_at TYPE timestamp without time zone,
ALTER COLUMN updated_at TYPE timestamp without time zone;

ALTER TABLE mr_deliveries
ALTER COLUMN created_at TYPE timestamp without time zone,
ALTER COLUMN supplier_invoice_date TYPE timestamp without time zone,
ALTER COLUMN updated_at TYPE timestamp without time zone;

ALTER TABLE mr_delivery_item_batches
ALTER COLUMN created_at TYPE timestamp without time zone,
ALTER COLUMN updated_at TYPE timestamp without time zone;

ALTER TABLE mr_delivery_items
ALTER COLUMN created_at TYPE timestamp without time zone,
ALTER COLUMN updated_at TYPE timestamp without time zone;

ALTER TABLE mr_goods_returned_note_items
ALTER COLUMN created_at TYPE timestamp without time zone,
ALTER COLUMN updated_at TYPE timestamp without time zone;

ALTER TABLE mr_goods_returned_notes
ALTER COLUMN created_at TYPE timestamp without time zone,
ALTER COLUMN updated_at TYPE timestamp without time zone;

ALTER TABLE mr_internal_batch_numbers
ALTER COLUMN created_at TYPE timestamp without time zone,
ALTER COLUMN updated_at TYPE timestamp without time zone;

ALTER TABLE mr_inventory_transactions
ALTER COLUMN created_at TYPE timestamp without time zone,
ALTER COLUMN updated_at TYPE timestamp without time zone;

ALTER TABLE mr_purchase_invoice_costs
ALTER COLUMN created_at TYPE timestamp without time zone,
ALTER COLUMN updated_at TYPE timestamp without time zone;

ALTER TABLE mr_purchase_order_items
ALTER COLUMN created_at TYPE timestamp without time zone,
ALTER COLUMN updated_at TYPE timestamp without time zone;

ALTER TABLE mr_purchase_orders
ALTER COLUMN created_at TYPE timestamp without time zone,
ALTER COLUMN updated_at TYPE timestamp without time zone,
ALTER COLUMN valid_until TYPE timestamp without time zone;

ALTER TABLE mr_sales_order_items
ALTER COLUMN created_at TYPE timestamp without time zone,
ALTER COLUMN updated_at TYPE timestamp without time zone;

ALTER TABLE mr_sales_orders
ALTER COLUMN created_at TYPE timestamp without time zone,
ALTER COLUMN shipped_at TYPE timestamp without time zone,
ALTER COLUMN updated_at TYPE timestamp without time zone;

ALTER TABLE mr_skus
ALTER COLUMN created_at TYPE timestamp without time zone,
ALTER COLUMN updated_at TYPE timestamp without time zone;

ALTER TABLE organizations
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE pack_material_products
ALTER COLUMN created_at TYPE timestamp without time zone,
ALTER COLUMN updated_at TYPE timestamp without time zone;

ALTER TABLE pack_material_product_variants
ALTER COLUMN created_at TYPE timestamp without time zone,
ALTER COLUMN updated_at TYPE timestamp without time zone;

ALTER TABLE parties
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE party_addresses
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE party_contact_methods
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE party_roles
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE people
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE printer_applications
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE printers
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE program_functions
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE programs
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE registered_mobile_devices
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE roles
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE security_groups
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE security_permissions
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE standard_pack_codes
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE std_fruit_size_counts
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE suppliers
ALTER COLUMN created_at TYPE timestamp without time zone,
ALTER COLUMN updated_at TYPE timestamp without time zone;

ALTER TABLE target_market_group_types
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE target_market_groups
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE target_markets
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE uoms
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE user_email_groups
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

-- vw_active_users
ALTER TABLE users
ALTER COLUMN created_at TYPE timestamp with time zone,
ALTER COLUMN updated_at TYPE timestamp with time zone;

ALTER TABLE vehicle_jobs
ALTER COLUMN created_at TYPE timestamp without time zone,
ALTER COLUMN updated_at TYPE timestamp without time zone,
ALTER COLUMN when_loaded TYPE timestamp without time zone,
ALTER COLUMN when_loading TYPE timestamp without time zone,
ALTER COLUMN when_offloaded TYPE timestamp without time zone,
ALTER COLUMN when_offloading TYPE timestamp without time zone;

ALTER TABLE vehicle_job_units
ALTER COLUMN created_at TYPE timestamp without time zone,
ALTER COLUMN updated_at TYPE timestamp without time zone,
ALTER COLUMN when_loaded TYPE timestamp without time zone,
ALTER COLUMN when_loading TYPE timestamp without time zone,
ALTER COLUMN when_offloaded TYPE timestamp without time zone,
ALTER COLUMN when_offloading TYPE timestamp without time zone;


-- Re-create dropped views:

CREATE OR REPLACE VIEW public.vw_active_users AS
 SELECT users.id,
    users.login_name,
    users.user_name,
    users.password_hash,
    users.email,
    users.active,
    users.created_at,
    users.updated_at
   FROM users
  WHERE users.active;

ALTER TABLE public.vw_active_users
  OWNER TO postgres;


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

