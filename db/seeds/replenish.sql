
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
        'New Purchase Order', 'Purchase Order', '/pack_material/replenish/mr_purchase_orders/preselect', 1);
--
-- INSERT INTO program_functions (program_id, program_function_name, group_name, url, program_function_sequence)
-- VALUES ((SELECT id FROM programs WHERE program_name = 'Replenish'
--                                        AND functional_area_id = (SELECT id FROM functional_areas
-- WHERE functional_area_name = 'Pack Material')),
--         'Search Purchase Orders', 'Purchase Order', '/search/mr_purchase_orders', 1);

INSERT INTO program_functions (program_id, program_function_name, group_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Replenish'
                                   AND functional_area_id = (SELECT id FROM functional_areas
                                                             WHERE functional_area_name = 'Pack Material')),
        'Purchase Orders', 'Purchase Order', '/list/mr_purchase_orders/with_params?key=incomplete', 2);

INSERT INTO program_functions (program_id, program_function_name, group_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Replenish'
                                   AND functional_area_id = (SELECT id FROM functional_areas
                                                             WHERE functional_area_name = 'Pack Material')),
        'Completed Purchase Orders', 'Purchase Order', '/list/mr_purchase_orders/with_params?key=completed', 3);

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
         'Deliveries', 'Deliveries', '/list/mr_deliveries/with_params?key=incomplete', 2);

-- PROGRAM FUNCTION Completed Deliveries
INSERT INTO program_functions (program_id, program_function_name, group_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Replenish'
          AND functional_area_id = (SELECT id FROM functional_areas
                                    WHERE functional_area_name = 'Pack Material')),
        'Completed Deliveries', 'Deliveries', '/list/mr_deliveries/with_params?key=completed', 5);

INSERT INTO mr_inventory_transaction_types (type_name) VALUES ('CREATE STOCK');
INSERT INTO mr_inventory_transaction_types (type_name) VALUES ('PUTAWAY');
INSERT INTO mr_inventory_transaction_types (type_name) VALUES ('ADHOC MOVE');
INSERT INTO mr_inventory_transaction_types (type_name) VALUES ('REMOVE STOCK');

INSERT INTO business_processes (process) VALUES ('DELIVERIES');
INSERT INTO business_processes (process) VALUES ('VEHICLE JOBS');
INSERT INTO business_processes (process) VALUES ('ADHOC TRANSACTIONS');
