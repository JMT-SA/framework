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
        1,
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
        2,
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
        2,
        NULL,
        false,
        false);