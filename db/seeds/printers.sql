
-- FUNCTIONAL AREA Label Designer
INSERT INTO functional_areas (functional_area_name)
VALUES ('Label Designer');


-- PROGRAM: Designs
INSERT INTO programs (program_name, program_sequence, functional_area_id)
VALUES ('Designs', 1,
        (SELECT id FROM functional_areas WHERE functional_area_name = 'Label Designer'));

-- LINK program to webapp
INSERT INTO programs_webapps (program_id, webapp)
VALUES ((SELECT id FROM programs
                   WHERE program_name = 'Designs'
                     AND functional_area_id = (SELECT id
                                               FROM functional_areas
                                               WHERE functional_area_name = 'Label Designer')),
                                               'Framework');


-- PROGRAM FUNCTION Available printers
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence,
                               group_name, restricted_user_access, show_in_iframe)
VALUES ((SELECT id FROM programs WHERE program_name = 'Designs'
          AND functional_area_id = (SELECT id FROM functional_areas
                                    WHERE functional_area_name = 'Label Designer')),
        'Available printers',
        '/list/printers',
        3,
        NULL,
        false,
        false);


-- PROGRAM FUNCTION Printer applications
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence,
                               group_name, restricted_user_access, show_in_iframe)
VALUES ((SELECT id FROM programs WHERE program_name = 'Designs'
          AND functional_area_id = (SELECT id FROM functional_areas
                                    WHERE functional_area_name = 'Label Designer')),
        'Printer applications',
        '/list/printer_applications',
        2,
        NULL,
        false,
        false);

