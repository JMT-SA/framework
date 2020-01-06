-- Add a description - for when used?
INSERT INTO security_permissions (security_permission)
VALUES ('read'),
('new'),
('edit'),
('user_maintenance'),
('user_permissions'),
('delete');


INSERT INTO security_groups (security_group_name)
VALUES ('basic'),
('view'),
('new'),
('user_maintainer'),
('user_permissions'),
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


INSERT INTO security_groups_security_permissions (security_group_id, security_permission_id)
SELECT g.id,
(SELECT id FROM security_permissions WHERE security_permission = 'read')
FROM security_groups g WHERE g.security_group_name = 'user_maintainer';
INSERT INTO security_groups_security_permissions (security_group_id, security_permission_id)
SELECT g.id,
(SELECT id FROM security_permissions WHERE security_permission = 'new')
FROM security_groups g WHERE g.security_group_name = 'user_maintainer';
INSERT INTO security_groups_security_permissions (security_group_id, security_permission_id)
SELECT g.id,
(SELECT id FROM security_permissions WHERE security_permission = 'edit')
FROM security_groups g WHERE g.security_group_name = 'user_maintainer';
INSERT INTO security_groups_security_permissions (security_group_id, security_permission_id)
SELECT g.id,
(SELECT id FROM security_permissions WHERE security_permission = 'delete')
FROM security_groups g WHERE g.security_group_name = 'user_maintainer';
INSERT INTO security_groups_security_permissions (security_group_id, security_permission_id)
SELECT g.id,
(SELECT id FROM security_permissions WHERE security_permission = 'user_maintenance')
FROM security_groups g WHERE g.security_group_name = 'user_maintainer';
INSERT INTO security_groups_security_permissions (security_group_id, security_permission_id)
SELECT g.id,
(SELECT id FROM security_permissions WHERE security_permission = 'user_permissions')
FROM security_groups g WHERE g.security_group_name = 'user_maintainer';


INSERT INTO security_groups_security_permissions (security_group_id, security_permission_id)
SELECT g.id,
(SELECT id FROM security_permissions WHERE security_permission = 'read')
FROM security_groups g WHERE g.security_group_name = 'user_permissions';
INSERT INTO security_groups_security_permissions (security_group_id, security_permission_id)
SELECT g.id,
(SELECT id FROM security_permissions WHERE security_permission = 'user_permissions')
FROM security_groups g WHERE g.security_group_name = 'user_permissions';

