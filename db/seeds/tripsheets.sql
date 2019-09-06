INSERT INTO programs (program_name, program_sequence, functional_area_id)
VALUES ('Tripsheets', 1, (SELECT id FROM functional_areas
                                              WHERE functional_area_name = 'Pack Material'));

INSERT INTO programs_webapps(program_id, webapp) VALUES (
      (SELECT id FROM programs
       WHERE program_name = 'Tripsheets'
         AND functional_area_id = (SELECT id FROM functional_areas
                                   WHERE functional_area_name = 'Pack Material')),
       'Framework');

-- Vehicle Types
-- NEW menu item
/*
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Tripsheets'
         AND functional_area_id = (SELECT id FROM functional_areas
                                   WHERE functional_area_name = 'Pack Material')),
         'New Vehicle Type', '/pack_material/tripsheets/vehicle_types/new', 1);
*/

-- LIST menu item
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Tripsheets'
         AND functional_area_id = (SELECT id FROM functional_areas
                                   WHERE functional_area_name = 'Pack Material')),
         'Vehicle Types', '/list/vehicle_types', 1);

-- SEARCH menu item
/*
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Tripsheets'
         AND functional_area_id = (SELECT id FROM functional_areas
                                   WHERE functional_area_name = 'Pack Material')),
         'Search Vehicle_types', '/search/vehicle_types', 2);
*/

-- Vehicles
-- NEW menu item
/*
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Tripsheets'
         AND functional_area_id = (SELECT id FROM functional_areas
                                   WHERE functional_area_name = 'Pack Material')),
         'New Vehicle', '/pack_material/tripsheets/vehicles/new', 1);
*/

-- LIST menu item
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Tripsheets'
         AND functional_area_id = (SELECT id FROM functional_areas
                                   WHERE functional_area_name = 'Pack Material')),
         'Vehicles', '/list/vehicles', 2);

-- SEARCH menu item
/*
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Tripsheets'
         AND functional_area_id = (SELECT id FROM functional_areas
                                   WHERE functional_area_name = 'Pack Material')),
         'Search Vehicles', '/search/vehicles', 2);
*/

-- Vehicle Jobs
-- NEW menu item
/*
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Tripsheets'
         AND functional_area_id = (SELECT id FROM functional_areas
                                   WHERE functional_area_name = 'Pack Material')),
         'New Vehicle Job', '/pack_material/tripsheets/vehicle_jobs/new', 1);
*/

-- LIST menu item
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Tripsheets'
         AND functional_area_id = (SELECT id FROM functional_areas
                                   WHERE functional_area_name = 'Pack Material')),
         'Vehicle Jobs', '/list/vehicle_jobs/with_params?key=incomplete', 3);

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Tripsheets'
                                   AND functional_area_id = (SELECT id FROM functional_areas
                                                             WHERE functional_area_name = 'Pack Material')),
        'Completed', '/list/vehicle_jobs/with_params?key=completed', 5);

-- SEARCH menu item
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Tripsheets'
         AND functional_area_id = (SELECT id FROM functional_areas
                                   WHERE functional_area_name = 'Pack Material')),
         'Search Vehicle Jobs', '/search/vehicle_jobs', 4);
