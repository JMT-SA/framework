
INSERT INTO functional_areas (functional_area_name)
VALUES ('Masterfiles');



-- PARTIES
INSERT INTO programs (program_name, program_sequence, functional_area_id)
VALUES ('Parties', 1, (SELECT id FROM functional_areas WHERE functional_area_name = 'Masterfiles'));

INSERT INTO programs_webapps (program_id, webapp)
VALUES ((SELECT id FROM programs WHERE program_name = 'Parties' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'Masterfiles')), 'Framework');

-- Grouped in Contact Details
INSERT INTO program_functions (program_id, program_function_name, group_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Parties'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Masterfiles')),
        'Addresses', 'Contact Details', '/list/addresses', 2);

INSERT INTO program_functions (program_id, program_function_name, group_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Parties'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Masterfiles')),
        'Contact_methods', 'Contact Details', '/list/contact_methods', 2);

-- Not Grouped
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



-- FRUIT
INSERT INTO programs (program_name, program_sequence, functional_area_id)
VALUES ('Fruit', 2, (SELECT id FROM functional_areas WHERE functional_area_name = 'Masterfiles'));

INSERT INTO programs_webapps (program_id, webapp)
VALUES ((SELECT id FROM programs WHERE program_name = 'Fruit' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'Masterfiles')), 'Framework');

-- Grouped in Commodities
INSERT INTO program_functions (program_id, program_function_name, group_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Fruit'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Masterfiles')),
        'Groups', 'Commodities', '/list/commodity_groups', 1);

INSERT INTO program_functions (program_id, program_function_name, group_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Fruit'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Masterfiles')),
        'Commodities', 'Commodities', '/list/commodities', 2);

-- Grouped in Cultivars
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence, group_name)
VALUES ((SELECT id FROM programs WHERE program_name = 'Fruit'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Masterfiles')),
        'Groups', '/list/cultivar_groups', 2, 'Cultivars');

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence, group_name)
VALUES ((SELECT id FROM programs WHERE program_name = 'Fruit'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Masterfiles')),
        'Cultivars', '/list/cultivars', 2, 'Cultivars');

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence, group_name)
VALUES ((SELECT id FROM programs WHERE program_name = 'Fruit'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Masterfiles')),
        'Marketing varieties', '/list/marketing_varieties', 2, 'Cultivars');

-- Grouped in Pack codes
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence, group_name)
VALUES ((SELECT id FROM programs WHERE program_name = 'Fruit'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Masterfiles')),
        'Basic', '/list/basic_pack_codes', 2, 'Pack codes');

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence, group_name)
VALUES ((SELECT id FROM programs WHERE program_name = 'Fruit'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Masterfiles')),
        'Standard', '/list/standard_pack_codes', 2, 'Pack codes');

-- Not Grouped
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Fruit'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Masterfiles')),
        'Std Fruit Size Counts', '/list/std_fruit_size_counts', 2);



-- TARGET MARKETS
INSERT INTO programs (program_name, program_sequence, functional_area_id)
VALUES ('Target Markets', 3, (SELECT id FROM functional_areas WHERE functional_area_name = 'Masterfiles'));

INSERT INTO programs_webapps (program_id, webapp)
VALUES ((SELECT id FROM programs WHERE program_name = 'Target Markets' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'Masterfiles')), 'Framework');

-- Grouped in Target Markets
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence, group_name)
VALUES ((SELECT id FROM programs WHERE program_name = 'Target Markets'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Masterfiles')),
        'Types', '/list/target_market_group_types', 2, 'Target markets');

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence, group_name)
VALUES ((SELECT id FROM programs WHERE program_name = 'Target Markets'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Masterfiles')),
        'Groups', '/list/target_market_groups', 2, 'Target markets');

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence, group_name)
VALUES ((SELECT id FROM programs WHERE program_name = 'Target Markets'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Masterfiles')),
        'Target markets', '/list/target_markets', 2, 'Target markets');

--Grouped in Destination
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence, group_name)
VALUES ((SELECT id FROM programs WHERE program_name = 'Target Markets'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Masterfiles')),
        'Regions', '/list/destination_regions', 2, 'Destination');

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence, group_name)
VALUES ((SELECT id FROM programs WHERE program_name = 'Target Markets'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Masterfiles')),
        'Countries', '/list/destination_countries', 2, 'Destination');

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence, group_name)
VALUES ((SELECT id FROM programs WHERE program_name = 'Target Markets'
                                       AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Masterfiles')),
        'Cities', '/list/destination_cities', 2, 'Destination');


