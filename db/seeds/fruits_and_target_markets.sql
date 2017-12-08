-- This should preferably be run after party.sql
-- INSERT INTO functional_areas (functional_area_name) VALUES ('Masterfiles');

-- FRUIT
INSERT INTO programs (program_name, program_sequence, functional_area_id)
VALUES ('Fruit', 1, (SELECT id FROM functional_areas WHERE functional_area_name = 'Masterfiles'));

-- Grouped in Commodities
-- Commodity Groups
-- Commodities

-- Grouped in Cultivars
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence, group_name)
VALUES ((SELECT id FROM programs WHERE program_name = 'Fruit'
AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Masterfiles')),
'Cultivar groups', '/list/cultivar_groups', 2, 'Cultivars');

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
'Basic codes', '/list/basic_pack_codes', 2, 'Pack codes');

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence, group_name)
VALUES ((SELECT id FROM programs WHERE program_name = 'Fruit'
AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Masterfiles')),
'Standard codes', '/list/standard_pack_codes', 2, 'Pack codes');

-- Not Grouped
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Fruit'
AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Masterfiles')),
'STD fruit size counts', '/list/std_fruit_size_counts', 2);
--
-- "I don't know if I want this to be a menu item or just a submenu item yet"
-- INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
-- VALUES ((SELECT id FROM programs WHERE program_name = 'TestFruit'
-- AND functional_area_id = (SELECT id FROM functional_areas
-- WHERE functional_area_name = 'Masterfiles')),
-- 'TestFruit actual counts for packs', '/list/fruit_actual_counts_for_packs', 2);
--
-- INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
-- VALUES ((SELECT id FROM programs WHERE program_name = 'TestFruit'
-- AND functional_area_id = (SELECT id FROM functional_areas
-- WHERE functional_area_name = 'Masterfiles')),
-- 'TestFruit size references', '/list/fruit_size_references', 2);
--
-- Add back to STD fruit size counts button to size references - doesn't make sense but it's better than nothing
-- SHOW: STD fruit size counts | fruit actual counts for pack after creation (possible popup grid here)

-- TARGET MARKETS
INSERT INTO programs (program_name, program_sequence, functional_area_id)
VALUES ('Target Markets', 1, (SELECT id FROM functional_areas WHERE functional_area_name = 'Masterfiles'));

-- Grouped in Target Markets
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence, group_name)
VALUES ((SELECT id FROM programs WHERE program_name = 'Target Markets'
AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Masterfiles')),
'TM group types', '/list/target_market_group_types', 2, 'Target Markets');

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence, group_name)
VALUES ((SELECT id FROM programs WHERE program_name = 'Target Markets'
AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Masterfiles')),
'TM groups', '/list/target_market_groups', 2, 'Target Markets');

INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence, group_name)
VALUES ((SELECT id FROM programs WHERE program_name = 'Target Markets'
AND functional_area_id = (SELECT id FROM functional_areas
WHERE functional_area_name = 'Masterfiles')),
'Target markets', '/list/target_markets', 2, 'Target Markets');

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










