INSERT INTO functional_areas (functional_area_name)
VALUES ('security');

INSERT INTO programs (program_name, program_sequence, functional_area_id)
VALUES ('menu', 1, (SELECT id FROM functional_areas WHERE functional_area_name = 'security'));

INSERT INTO programs_webapps (program_id, webapp)
VALUES ((SELECT id FROM programs WHERE program_name = 'menu' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'security')), 'Framework');

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'menu' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'security')), 'list menu definitions', '/list/menu_definitions', 1);


INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'menu' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'security')), 'security groups', '/list/security_groups', 1);

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'menu' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'security')), 'security permissions', '/list/security_permissions', 1);



INSERT INTO functional_areas (functional_area_name)
VALUES ('dataminer');

INSERT INTO programs (program_name, program_sequence, functional_area_id)
VALUES ('reports', 1, (SELECT id FROM functional_areas WHERE functional_area_name = 'dataminer'));

INSERT INTO programs_webapps (program_id, webapp)
VALUES ((SELECT id FROM programs WHERE program_name = 'reports' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'dataminer')), 'Framework');

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'reports' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'dataminer')), 'list reports', '/dataminer/reports', 1);

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'reports' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'dataminer')), 'admin', '/dataminer/admin', 2);

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence, restricted_user_access)
VALUES ((SELECT id FROM programs WHERE program_name = 'reports' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'dataminer')), 'Admin grids', '/dataminer/admin/grids', 3, 't');

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'reports' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'dataminer')), 'Prepared Reports', '/dataminer/prepared_reports/list', 4);

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence, restricted_user_access)
VALUES ((SELECT id FROM programs WHERE program_name = 'reports' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'dataminer')), 'ALL Prepared Reports', '/dataminer/prepared_reports/list_all', 5, 't');


INSERT INTO functional_areas (functional_area_name)
VALUES ('Development');

INSERT INTO programs (program_name, program_sequence, functional_area_id)
VALUES ('Generators', 1, (SELECT id FROM functional_areas WHERE functional_area_name = 'Development'));

INSERT INTO programs_webapps (program_id, webapp)
VALUES ((SELECT id FROM programs WHERE program_name = 'Generators' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'Development')), 'Framework');

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Generators' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'Development')), 'New Scaffold', '/development/generators/scaffolds/new', 1);

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Generators' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'Development')), 'Documentation', '/developer_documentation/start', 2);

INSERT INTO programs (program_name, program_sequence, functional_area_id)
VALUES ('Logging', 3, (SELECT id FROM functional_areas WHERE functional_area_name = 'Development'));

INSERT INTO programs_webapps (program_id, webapp)
VALUES ((SELECT id FROM programs WHERE program_name = 'Logging' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'Development')), 'Framework');

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Logging' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'Development')), 'Search logged actions', '/search/logged_actions', 1);

INSERT INTO programs (program_name, program_sequence, functional_area_id)
VALUES ('Masterfiles', 2, (SELECT id FROM functional_areas WHERE functional_area_name = 'Development'));

INSERT INTO programs_webapps (program_id, webapp)
VALUES ((SELECT id FROM programs WHERE program_name = 'Masterfiles' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'Development')), 'Framework');

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Masterfiles' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'Development')), 'Users', '/list/users', 1);

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Masterfiles'
         AND functional_area_id = (SELECT id FROM functional_areas
                                   WHERE functional_area_name = 'Development')),
         'User_email_groups', '/list/user_email_groups', 2);

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Masterfiles' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'Development')), 'Contact Method Types', '/list/contact_method_types', 1);

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Masterfiles' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'Development')), 'Address Types', '/list/address_types', 1);

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Masterfiles' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'Development')), 'Party Roles', '/list/roles', 1);

-- Registered Mobile Devices menu:
INSERT INTO functional_areas (functional_area_name, rmd_menu)
VALUES ('RMD', true);
