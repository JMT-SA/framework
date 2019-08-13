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
VALUES ('Stock Adjustments', 2,
        (SELECT id FROM functional_areas WHERE functional_area_name = 'RMD'));

-- LINK program to webapp
INSERT INTO programs_webapps (program_id, webapp)
VALUES ((SELECT id FROM programs
WHERE program_name = 'Stock Adjustments'
      AND functional_area_id = (SELECT id
                                FROM functional_areas
                                WHERE functional_area_name = 'RMD')),
        'Framework');

-- PROGRAM FUNCTION Bulk Stock Adjustment
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence,
                               group_name, restricted_user_access, show_in_iframe)
VALUES ((SELECT id FROM programs WHERE program_name = 'Stock Adjustments'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'RMD')),
        'Adjust Item',
        '/rmd/stock_adjustments/adjust_item/new',
        5,
        NULL,
        false,
        false);

-- PROGRAM FUNCTION Stock Move
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence,
                               group_name, restricted_user_access, show_in_iframe)
VALUES ((SELECT id FROM programs WHERE program_name = 'Stock Adjustments'
                                   AND functional_area_id = (SELECT id FROM functional_areas
                                                             WHERE functional_area_name = 'RMD')),
        'Move',
        '/rmd/stock/moves/new',
        5,
        NULL,
        false,
        false);

UPDATE programs p
SET program_name = 'Stock'
WHERE p.functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'RMD')
  AND p.program_name = 'Stock Adjustments';

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
