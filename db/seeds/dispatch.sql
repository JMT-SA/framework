-- FUNCTIONAL AREA Pack Material
-- INSERT INTO functional_areas (functional_area_name) VALUES ('Pack Material');

-- PROGRAM: Dispatch
INSERT INTO programs (program_name, program_sequence, functional_area_id)
VALUES ('Dispatch', 20, (SELECT id FROM functional_areas
                                              WHERE functional_area_name = 'Pack Material'));

-- LINK program to webapp
INSERT INTO programs_webapps(program_id, webapp) VALUES (
      (SELECT id FROM programs
       WHERE program_name = 'Dispatch'
         AND functional_area_id = (SELECT id FROM functional_areas
                                   WHERE functional_area_name = 'Pack Material')),
       'Framework');

-- NEW menu item
-- PROGRAM FUNCTION New MrGoodsReturnedNote

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence, group_name)
VALUES ((SELECT id FROM programs WHERE program_name = 'Dispatch'
         AND functional_area_id = (SELECT id FROM functional_areas
                                   WHERE functional_area_name = 'Pack Material')),
         'New Return', '/pack_material/dispatch/mr_goods_returned_notes/new', 1, 'GRNs');


-- LIST menu item
-- PROGRAM FUNCTION Mr_goods_returned_notes
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence, group_name)
VALUES ((SELECT id FROM programs WHERE program_name = 'Dispatch'
         AND functional_area_id = (SELECT id FROM functional_areas
                                   WHERE functional_area_name = 'Pack Material')),
         'Returns', '/list/mr_goods_returned_notes/with_params?key=unshipped', 2, 'GRNs');

-- PROGRAM FUNCTION Mr_goods_returned_notes
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence, group_name)
VALUES ((SELECT id FROM programs WHERE program_name = 'Dispatch'
                                   AND functional_area_id = (SELECT id FROM functional_areas
                                                             WHERE functional_area_name = 'Pack Material')),
        'Shipped Returns', '/list/mr_goods_returned_notes/with_params?key=shipped', 3, 'GRNs');

INSERT INTO business_processes (process) VALUES ('GOODS RETURN');

-- SALES
-- NEW menu item
-- PROGRAM FUNCTION New SalesOrder

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence, group_name)
VALUES ((SELECT id FROM programs WHERE program_name = 'Dispatch'
                                   AND functional_area_id = (SELECT id FROM functional_areas
                                                             WHERE functional_area_name = 'Pack Material')),
        'New Return', '/pack_material/dispatch/mr_goods_returned_notes/new', 1, 'GRNs');


-- LIST menu item
-- PROGRAM FUNCTION Mr_goods_returned_notes
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence, group_name)
VALUES ((SELECT id FROM programs WHERE program_name = 'Dispatch'
                                   AND functional_area_id = (SELECT id FROM functional_areas
                                                             WHERE functional_area_name = 'Pack Material')),
        'Returns', '/list/mr_goods_returned_notes/with_params?key=unshipped', 2, 'GRNs');

-- PROGRAM FUNCTION Mr_goods_returned_notes
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence, group_name)
VALUES ((SELECT id FROM programs WHERE program_name = 'Dispatch'
                                   AND functional_area_id = (SELECT id FROM functional_areas
                                                             WHERE functional_area_name = 'Pack Material')),
        'Shipped Returns', '/list/mr_goods_returned_notes/with_params?key=shipped', 3, 'GRNs');

INSERT INTO business_processes (process) VALUES ('GOODS RETURN');
