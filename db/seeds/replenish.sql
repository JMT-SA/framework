
INSERT INTO programs (program_name, program_sequence, functional_area_id)
VALUES ('Replenish', 1, (SELECT id FROM functional_areas
WHERE functional_area_name = 'Pack Material'));

INSERT INTO programs_webapps(program_id, webapp) VALUES (
  (SELECT id FROM programs
  WHERE program_name = 'Replenish'
        AND functional_area_id = (SELECT id FROM functional_areas
  WHERE functional_area_name = 'Pack Material')),
  'Framework');

-- Purchase Orders
INSERT INTO program_functions (program_id, program_function_name, group_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Replenish'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Pack Material')),
        'New Purchase Order', 'Purchase Orders', '/pack_material/replenish/mr_purchase_orders/preselect', 1);

INSERT INTO program_functions (program_id, program_function_name, group_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Replenish'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Pack Material')),
        'Purchase Orders', 'Purchase Orders', '/list/mr_purchase_orders', 2);

INSERT INTO program_functions (program_id, program_function_name, group_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Replenish'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Pack Material')),
        'Search Purchase Orders', 'Purchase Orders', '/search/mr_purchase_orders', 2);


-- Delivery Terms
INSERT INTO program_functions (program_id, program_function_name, group_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Replenish'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Pack Material')),
        'Delivery Terms', 'Purchase Orders', '/list/mr_delivery_terms', 2);

-- Deliveries
INSERT INTO program_functions (program_id, program_function_name, group_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Replenish'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Pack Material')),
        'New Delivery', 'Deliveries', '/pack_material/replenish/mr_deliveries/new', 1);

INSERT INTO program_functions (program_id, program_function_name, group_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Replenish'
         AND functional_area_id = (SELECT id FROM functional_areas
                                   WHERE functional_area_name = 'Pack Material')),
         'Deliveries', 'Deliveries', '/list/mr_deliveries', 2);

INSERT INTO program_functions (program_id, program_function_name, group_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Replenish'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Pack Material')),
        'Delivery Items/Batches', 'Deliveries', '/list/mr_delivery_items_batches', 2);

INSERT INTO mr_inventory_transaction_types (type_name) VALUES ('CREATE STOCK');
INSERT INTO mr_inventory_transaction_types (type_name) VALUES ('PUTAWAY');
INSERT INTO mr_inventory_transaction_types (type_name) VALUES ('ADHOC MOVE');
INSERT INTO mr_inventory_transaction_types (type_name) VALUES ('REMOVE STOCK');

INSERT INTO crossbeams_framework.public.business_processes (process) VALUES ('DELIVERIES');
INSERT INTO crossbeams_framework.public.business_processes (process) VALUES ('VEHICLE JOBS');
INSERT INTO crossbeams_framework.public.business_processes (process) VALUES ('ADHOC TRANSACTIONS');


-- SKU Locations grid
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Replenish'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Pack Material')),
        'SKU Locations', '/list/sku_locations', 2);


-- MR Cost Types

INSERT INTO programs (program_name, program_sequence, functional_area_id)
VALUES ('Pack Material', 1, (SELECT id FROM functional_areas WHERE functional_area_name = 'Masterfiles'));

INSERT INTO programs_webapps(program_id, webapp) VALUES (
  (SELECT id FROM programs
  WHERE program_name = 'Pack Material'
        AND functional_area_id = (SELECT id FROM functional_areas
  WHERE functional_area_name = 'Masterfiles')),
  'Framework');

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Pack Material'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Masterfiles')),
        'Cost Types', '/list/mr_cost_types', 2);
