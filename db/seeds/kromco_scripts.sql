-- Create SKUs for all the Products
-- Prerequisite: All supplier links need to be set up
INSERT INTO public.mr_skus(mr_product_variant_id, owner_party_role_id, mr_internal_batch_number_id)
SELECT id, (SELECT pr.id FROM party_roles pr JOIN organizations o ON o.party_id = pr.party_id JOIN roles r ON r.id = pr.role_id WHERE r.name = 'IMPLEMENTATION_OWNER' AND o.short_description = 'KROMCO (PTY) LTD'),
       (SELECT id FROM public.mr_internal_batch_numbers ORDER BY id DESC LIMIT 1)
FROM material_resource_product_variants
WHERE NOT EXISTS (SELECT id FROM mr_skus WHERE mr_product_variant_id = material_resource_product_variants.id);

-- KROMCO SPECIFIC
-- They only have one internal batch number and will not be using batch tracking
update public.material_resource_product_variants
set use_fixed_batch_number = true,
    mr_internal_batch_number_id = (SELECT id FROM public.mr_internal_batch_numbers ORDER BY id DESC LIMIT 1)
where material_resource_product_variants.use_fixed_batch_number = false;

-- Empty all Pack Material Workflow DATA
-- -- clean bulk stock adjustments
-- DELETE FROM mr_bulk_stock_adjustment_items;
-- DELETE FROM mr_bulk_stock_adjustment_prices;
-- DELETE FROM mr_bulk_stock_adjustments_locations;
-- DELETE FROM mr_bulk_stock_adjustments_sku_numbers;
-- DELETE FROM mr_bulk_stock_adjustments;
-- -- REMOVE STOCK
-- DELETE FROM mr_sku_locations;
-- -- clean deliveries
-- DELETE FROM mr_skus where mr_delivery_item_batch_id is not null;
-- DELETE FROM mr_delivery_item_batches;
-- DELETE FROM mr_delivery_items;
-- DELETE FROM mr_purchase_invoice_costs;
-- DELETE FROM mr_deliveries;
-- -- clean purchase orders
-- DELETE FROM mr_purchase_order_items;
-- DELETE FROM mr_purchase_order_costs;
-- DELETE FROM mr_purchase_orders;
-- -- clean transactions
-- DELETE FROM mr_inventory_transaction_items;
-- DELETE FROM mr_inventory_transactions;
-- NOTE: we probably want to clear out statuses and audits for these tables as well

-- RESET SEQUENCES
ALTER SEQUENCE doc_seqs_po_number RESTART WITH 1;
ALTER SEQUENCE doc_seqs_delivery_number RESTART WITH 1;
ALTER SEQUENCE doc_seqs_waybill_number RESTART WITH 1;
-- ALTER SEQUENCE doc_seqs_sku_number RESTART WITH 1;
-- ALTER SEQUENCE doc_seqs_stock_adjustment_number RESTART WITH 1;
