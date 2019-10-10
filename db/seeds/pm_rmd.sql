-- Registered Mobile Devices menu:


-- See basic_menu.sql for RMD setup & basic menu & check barcode

-- PROGRAM: Deliveries
INSERT INTO programs (program_name, program_sequence, functional_area_id)
VALUES ('Deliveries', 2,
        (SELECT id FROM functional_areas WHERE functional_area_name = 'RMD'));

-- LINK program to webapp
INSERT INTO programs_webapps (program_id, webapp)
VALUES ((SELECT id FROM programs
                   WHERE program_name = 'Deliveries'
                     AND functional_area_id = (SELECT id
                                               FROM functional_areas
                                               WHERE functional_area_name = 'RMD')),
                                               'Framework');


-- PROGRAM FUNCTION Putaway
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence,
                               group_name, restricted_user_access, show_in_iframe)
VALUES ((SELECT id FROM programs WHERE program_name = 'Deliveries'
          AND functional_area_id = (SELECT id FROM functional_areas
                                    WHERE functional_area_name = 'RMD')),
        'Putaway',
        '/rmd/deliveries/putaway',
        3,
        NULL,
        false,
        false);


-- PROGRAM FUNCTION Delivery status
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence,
                               group_name, restricted_user_access, show_in_iframe)
VALUES ((SELECT id FROM programs WHERE program_name = 'Deliveries'
          AND functional_area_id = (SELECT id FROM functional_areas
                                    WHERE functional_area_name = 'RMD')),
        'Delivery status',
        '/rmd/deliveries/status',
        4,
        NULL,
        false,
        false);

-- PROGRAM: Stock Adjustments
INSERT INTO programs (program_name, program_sequence, functional_area_id)
VALUES ('Stock', 3,
        (SELECT id FROM functional_areas WHERE functional_area_name = 'RMD'));

-- LINK program to webapp
INSERT INTO programs_webapps (program_id, webapp)
VALUES ((SELECT id FROM programs
WHERE program_name = 'Stock'
      AND functional_area_id = (SELECT id
                                FROM functional_areas
                                WHERE functional_area_name = 'RMD')),
        'Framework');

-- PROGRAM FUNCTION Bulk Stock Adjustment
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence,
                               group_name, restricted_user_access, show_in_iframe)
VALUES ((SELECT id FROM programs WHERE program_name = 'Stock'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'RMD')),
        'Adjust Item',
        '/rmd/stock_adjustments/adjust_item/new',
        1,
        NULL,
        false,
        false);

-- PROGRAM FUNCTION Stock Move
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence,
                               group_name, restricted_user_access, show_in_iframe)
VALUES ((SELECT id FROM programs WHERE program_name = 'Stock'
                                   AND functional_area_id = (SELECT id FROM functional_areas
                                                             WHERE functional_area_name = 'RMD')),
        'Move',
        '/rmd/stock/moves/new',
        2,
        NULL,
        false,
        false);

-- UPDATE programs p
-- SET program_name = 'Stock'
-- WHERE p.functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'RMD')
--   AND p.program_name = 'Stock Adjustments';

-- PROGRAM: Vehicle
INSERT INTO programs (program_name, program_sequence, functional_area_id)
VALUES ('Vehicle', 4,
        (SELECT id FROM functional_areas WHERE functional_area_name = 'RMD'));

-- LINK program to webapp
INSERT INTO programs_webapps (program_id, webapp)
VALUES ((SELECT id FROM programs
         WHERE program_name = 'Vehicle'
           AND functional_area_id = (SELECT id
                                     FROM functional_areas
                                     WHERE functional_area_name = 'RMD')),
        'Framework');

-- PROGRAM FUNCTION Vehicle Load
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence,
                               group_name, restricted_user_access, show_in_iframe)
VALUES ((SELECT id FROM programs WHERE program_name = 'Vehicle'
                                   AND functional_area_id = (SELECT id FROM functional_areas
                                                             WHERE functional_area_name = 'RMD')),
        'Load',
        '/rmd/vehicles/load/new',
        5,
        NULL,
        false,
        false);

-- PROGRAM FUNCTION Vehicle Offload
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence,
                               group_name, restricted_user_access, show_in_iframe)
VALUES ((SELECT id FROM programs WHERE program_name = 'Vehicle'
                                   AND functional_area_id = (SELECT id FROM functional_areas
                                                             WHERE functional_area_name = 'RMD')),
        'Offload',
        '/rmd/vehicles/offload/new',
        5,
        NULL,
        false,
        false);

-- PROGRAM: PRINTING
INSERT INTO programs (program_name, program_sequence, functional_area_id)
VALUES ('Printing', 3,
        (SELECT id FROM functional_areas WHERE functional_area_name = 'RMD'));

-- LINK program to webapp
INSERT INTO programs_webapps (program_id, webapp)
VALUES ((SELECT id
         FROM programs
         WHERE program_name = 'Printing'
           AND functional_area_id = (SELECT id
                                     FROM functional_areas
                                     WHERE functional_area_name = 'RMD')),
        'Framework');

-- PROGRAM FUNCTION Print SKU Label
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence,
                               group_name, restricted_user_access, show_in_iframe)
VALUES ((SELECT id
         FROM programs
         WHERE program_name = 'Printing'
           AND functional_area_id = (SELECT id
                                     FROM functional_areas
                                     WHERE functional_area_name = 'RMD')),
        'SKU Label',
        '/rmd/printing/sku_label/new',
        5,
        NULL,
        false,
        false);

UPDATE program_functions pf
SET program_function_sequence = 1
WHERE pf.program_function_name = 'Putaway';
UPDATE program_functions pf
SET program_function_sequence = 2
WHERE pf.program_function_name = 'Delivery status';
UPDATE programs p
SET program_sequence = 3
WHERE p.functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'RMD')
  AND p.program_name = 'Stock';
UPDATE program_functions pf
SET program_function_sequence = 1
WHERE pf.program_function_name = 'Adjust Item';
UPDATE program_functions pf
SET program_function_sequence = 2
WHERE pf.program_function_name = 'Move';
UPDATE program_functions pf
SET program_function_sequence = 1
WHERE pf.program_function_name = 'Load';
UPDATE program_functions pf
SET program_function_sequence = 2
WHERE pf.program_function_name = 'Offload';
UPDATE programs p
SET program_sequence = 5
WHERE p.functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'RMD')
AND p.program_name = 'Printing';
UPDATE program_functions pf
SET program_function_sequence = 1
WHERE pf.program_function_name = 'SKU Label';

INSERT INTO program_functions (program_id, program_function_name, group_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Replenish'
                                   AND functional_area_id = (SELECT id FROM functional_areas
                                                             WHERE functional_area_name = 'Pack Material')),
        'Completed Purchase Orders', 'Purchase Order', '/list/mr_purchase_orders/with_params?key=completed', 3);
UPDATE program_functions pf
SET url = '/list/mr_purchase_orders/with_params?key=incomplete'
WHERE pf.program_function_name = 'Purchase Orders';
