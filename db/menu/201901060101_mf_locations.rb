Crossbeams::MenuMigrations::Migrator.migration('Framework') do
  up do
    add_program 'Locations', functional_area: 'Masterfiles'
    add_program_function 'Types', functional_area: 'Masterfiles', program: 'Locations', url: '/list/location_types'
    add_program_function 'Storage Types', functional_area: 'Masterfiles', program: 'Locations', url: '/list/location_storage_types', seq: 2
    add_program_function 'Storage Definitions', functional_area: 'Masterfiles', program: 'Locations', url: '/list/location_storage_definitions', seq: 3
    add_program_function 'Assignments', functional_area: 'Masterfiles', program: 'Locations', url: '/list/location_assignments', seq: 4
    add_program_function 'Locations', functional_area: 'Masterfiles', program: 'Locations', url: '/list/locations', seq: 5
    add_program_function 'Search Locations', functional_area: 'Masterfiles', program: 'Locations', url: '/search/locations', seq: 6
  end

  down do
    drop_program 'Locations', functional_area: 'Masterfiles'
  end
end
