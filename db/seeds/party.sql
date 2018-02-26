-- INSERT INTO functional_areas (functional_area_name) VALUES ('Masterfiles');

INSERT INTO programs (program_name, program_sequence, functional_area_id)
VALUES ('Parties', 1, (SELECT id FROM functional_areas WHERE functional_area_name = 'Masterfiles'));

INSERT INTO programs_webapps (program_id, webapp)
VALUES ((SELECT id FROM programs WHERE program_name = 'Parties' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'Masterfiles')), 'Framework');


INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Parties' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'Masterfiles')), 'Commodity Groups', '/list/commodity_groups', 1);

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Parties' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'Masterfiles')), 'Commodities', '/list/commodities', 2);

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Parties'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Masterfiles')),
        'Addresses', '/list/addresses', 2);

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Parties'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Masterfiles')),
        'Contact_methods', '/list/contact_methods', 2);

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Parties'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Masterfiles')),
        'Organizations', '/list/organizations', 2);

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Parties'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Masterfiles')),
        'People', '/list/people', 2);
