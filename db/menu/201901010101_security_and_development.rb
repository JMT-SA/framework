Crossbeams::MenuMigrations::Migrator.migration('Framework') do
  up do
    add_functional_area 'Security'
    add_program 'Menu', functional_area: 'Security'
    add_program_function 'List Menu Definitions', functional_area: 'Security', program: 'Menu', url: '/list/menu_definitions'
    add_program_function 'Security Groups', functional_area: 'Security', program: 'Menu', url: '/list/security_groups', seq: 2
    add_program_function 'Security Permissions', functional_area: 'Security', program: 'Menu', url: '/list/security_permissions', seq: 3

    add_program 'RMD', functional_area: 'Security'
    add_program_function 'Registered Mobile Devices', functional_area: 'Security', program: 'RMD', url: '/list/registered_mobile_devices'

    add_functional_area 'Development'
    add_program 'Generators', functional_area: 'Development'
    add_program_function 'New Scaffold', functional_area: 'Development', program: 'Generators', url: '/development/generators/scaffolds/new'
    add_program_function 'Documentation', functional_area: 'Development', program: 'Generators', url: '/developer_documentation/start', seq: 2

    add_program 'Masterfiles', functional_area: 'Development', seq: 2
    add_program_function 'Users', functional_area: 'Development', program: 'Masterfiles', url: '/list/users'
    add_program_function 'User Email Groups', functional_area: 'Development', program: 'Masterfiles', url: '/list/user_email_groups', seq: 2
    add_program_function 'Contact Method types', functional_area: 'Development', program: 'Masterfiles', url: '/list/contact_method_types', seq: 3
    add_program_function 'Address types', functional_area: 'Development', program: 'Masterfiles', url: '/list/address_types', seq: 4
    add_program_function 'Party Roles', functional_area: 'Development', program: 'Masterfiles', url: '/list/roles', seq: 5

    add_program 'Logging', functional_area: 'Development', seq: 3
    add_program_function 'Search logged actions', functional_area: 'Development', program: 'Logging', url: '/search/logged_actions'
  end

  down do
    drop_functional_area 'Security'
    drop_functional_area 'Development'
  end
end
