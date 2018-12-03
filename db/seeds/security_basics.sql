-- Add a description - for when used?
INSERT INTO security_permissions (security_permission)
VALUES ('read'),
('new'),
('edit'),
('delete');


INSERT INTO security_groups (security_group_name)
VALUES ('basic'),
('view'),
('new'),
('edit');

INSERT INTO security_groups_security_permissions (security_group_id, security_permission_id)
SELECT g.id,
(SELECT id FROM security_permissions WHERE security_permission = 'read')
FROM security_groups g WHERE g.security_group_name = 'basic';
INSERT INTO security_groups_security_permissions (security_group_id, security_permission_id)
SELECT g.id,
(SELECT id FROM security_permissions WHERE security_permission = 'new')
FROM security_groups g WHERE g.security_group_name = 'basic';
INSERT INTO security_groups_security_permissions (security_group_id, security_permission_id)
SELECT g.id,
(SELECT id FROM security_permissions WHERE security_permission = 'edit')
FROM security_groups g WHERE g.security_group_name = 'basic';
INSERT INTO security_groups_security_permissions (security_group_id, security_permission_id)
SELECT g.id,
(SELECT id FROM security_permissions WHERE security_permission = 'delete')
FROM security_groups g WHERE g.security_group_name = 'basic';

INSERT INTO security_groups_security_permissions (security_group_id, security_permission_id)
SELECT g.id,
(SELECT id FROM security_permissions WHERE security_permission = 'read')
FROM security_groups g WHERE g.security_group_name = 'view';

INSERT INTO security_groups_security_permissions (security_group_id, security_permission_id)
SELECT g.id,
(SELECT id FROM security_permissions WHERE security_permission = 'new')
FROM security_groups g WHERE g.security_group_name = 'new';

INSERT INTO security_groups_security_permissions (security_group_id, security_permission_id)
SELECT g.id,
(SELECT id FROM security_permissions WHERE security_permission = 'edit')
FROM security_groups g WHERE g.security_group_name = 'edit';

------------------------

INSERT INTO programs (program_name, program_sequence, functional_area_id)
VALUES ('Rmd', 1, (SELECT id FROM functional_areas
                                              WHERE functional_area_name = 'Security'));

INSERT INTO programs_webapps(program_id, webapp) VALUES (
      (SELECT id FROM programs
       WHERE program_name = 'Rmd'
         AND functional_area_id = (SELECT id FROM functional_areas
                                   WHERE functional_area_name = 'Security')),
       'Framework');


INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
VALUES ((SELECT id FROM programs WHERE program_name = 'Rmd'
         AND functional_area_id = (SELECT id FROM functional_areas
                                   WHERE functional_area_name = 'Security')),
         'Registered_mobile_devices', '/list/registered_mobile_devices', 2);
