INSERT INTO functional_areas (functional_area_name)
VALUES ('security');

INSERT INTO programs (program_name, program_sequence, functional_area_id)
VALUES ('menu', 1, (SELECT id FROM functional_areas WHERE functional_area_name = 'security'));

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'menu' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'security')), 'list menu definitions', '/list/menu_definitions', 1);



INSERT INTO functional_areas (functional_area_name)
VALUES ('dataminer');

INSERT INTO programs (program_name, program_sequence, , functional_area_id)
VALUES ('reports', 1, (SELECT id FROM functional_areas WHERE functional_area_name = 'dataminer'));

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'reports' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'dataminer')), 'list reports', '/dataminer/', 1);

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'reports' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'dataminer')), 'admin', '/dataminer/admin/', 2);