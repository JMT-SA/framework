-- This is created in the backend per domain - NO CRUD AVAILABLE for users
INSERT INTO material_resource_domains (domain_name, product_table_name, variant_table_name)
VALUES ('Pack Material', 'pack_material_products', 'pack_material_product_variants');

-- LOCATION STORAGE TYPES
INSERT INTO location_storage_types (storage_type_code, location_short_code_prefix) VALUES ('Pack Material', '01');
-- LOCATION TYPES
INSERT INTO location_types (location_type_code, short_code) VALUES ('RECEIVING BAY', 'RB');

-- INVENTORY TRANSACTION TYPES
INSERT INTO mr_inventory_transaction_types (type_name) VALUES ('CREATE STOCK');
INSERT INTO mr_inventory_transaction_types (type_name) VALUES ('PUTAWAY');
INSERT INTO mr_inventory_transaction_types (type_name) VALUES ('ADHOC MOVE');
INSERT INTO mr_inventory_transaction_types (type_name) VALUES ('REMOVE STOCK');

-- BUSINESS PROCESSES
INSERT INTO business_processes (process) VALUES ('ADHOC TRANSACTIONS');
INSERT INTO business_processes (process) VALUES ('BULK STOCK ADJUSTMENTS');
INSERT INTO business_processes (process) VALUES ('DELIVERIES');
INSERT INTO business_processes (process) VALUES ('DESTROYED FOR WASTE');
INSERT INTO business_processes (process) VALUES ('GOODS RETURN');
INSERT INTO business_processes (process) VALUES ('STOCK TAKE');
INSERT INTO business_processes (process) VALUES ('STOCK TAKE ON');
INSERT INTO business_processes (process) VALUES ('STOCK SALES');
INSERT INTO business_processes (process) VALUES ('VEHICLE JOBS');
INSERT INTO business_processes (process) VALUES ('WASTE SALES');
INSERT INTO business_processes (process) VALUES ('WASTE CREATED');
INSERT INTO business_processes (process) VALUES ('SALES ORDERS');
INSERT INTO business_processes (process) VALUES ('CONSUMPTION');
