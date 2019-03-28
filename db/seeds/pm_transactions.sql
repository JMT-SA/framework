-- ADHOC Transactions
INSERT INTO programs (program_name, program_sequence, functional_area_id)
VALUES ('Transactions', 1, (SELECT id FROM functional_areas
WHERE functional_area_name = 'Pack Material'));

INSERT INTO programs_webapps(program_id, webapp) VALUES (
  (SELECT id FROM programs
  WHERE program_name = 'Transactions'
        AND functional_area_id = (SELECT id FROM functional_areas
  WHERE functional_area_name = 'Pack Material')),
  'Framework');

-- SKU locations Grid
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Transactions'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Pack Material')),
        'SKU Locations', '/list/sku_locations', 1);

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Transactions'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Pack Material')),
        'Search SKU Locations', '/search/sku_locations', 2);

-- SKU Transaction History
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Transactions'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Pack Material')),
        'SKU Transaction History', '/list/sku_transaction_history', 3);

-- Bulk Stock Adjustments
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Transactions'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Pack Material')),
        'Bulk Stock Adjustments', '/list/mr_bulk_stock_adjustments', 4);


INSERT INTO crossbeams_framework.public.business_processes (process) VALUES ('BULK STOCK ADJUSTMENT');
INSERT INTO crossbeams_framework.public.business_processes (process) VALUES ('STOCK TAKE');
INSERT INTO crossbeams_framework.public.business_processes (process) VALUES ('STOCK TAKE ON');

INSERT INTO crossbeams_framework.public.location_storage_types (storage_type_code) VALUES ('Pack Material');

-- Tripsheet Grid
--   Vehicle Types
--   Vehicles
--   Vehicle Jobs
