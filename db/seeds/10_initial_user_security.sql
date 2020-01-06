INSERT INTO programs_users (user_id, program_id, security_group_id)
VALUES ((SELECT id FROM users ORDER BY id LIMIT 1),
  (SELECT id FROM programs WHERE program_name = 'Menu' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'Security')),
  (SELECT id FROM security_groups g WHERE g.security_group_name = 'basic'));

INSERT INTO programs_users (user_id, program_id, security_group_id)
VALUES ((SELECT id FROM users ORDER BY id LIMIT 1),
  (SELECT id FROM programs WHERE program_name = 'Reports' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'Dataminer')),
  (SELECT id FROM security_groups g WHERE g.security_group_name = 'basic'));

INSERT INTO programs_users (user_id, program_id, security_group_id)
VALUES ((SELECT id FROM users ORDER BY id LIMIT 1),
  (SELECT id FROM programs WHERE program_name = 'Generators' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'Development')),
  (SELECT id FROM security_groups g WHERE g.security_group_name = 'basic'));

INSERT INTO programs_users (user_id, program_id, security_group_id)
VALUES ((SELECT id FROM users ORDER BY id LIMIT 1),
  (SELECT id FROM programs WHERE program_name = 'Masterfiles' AND functional_area_id = (SELECT id FROM functional_areas WHERE functional_area_name = 'Development')),
  (SELECT id FROM security_groups g WHERE g.security_group_name = 'user_maintainer'));
