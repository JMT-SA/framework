Crossbeams::MenuMigrations::Migrator.migration('Framework') do
  up do
    add_functional_area 'Dataminer'
    add_program 'Reports', functional_area: 'Dataminer'
    add_program_function 'List Reports', functional_area: 'Dataminer', program: 'Reports', url: '/dataminer/reports'
    add_program_function 'Report Admin', functional_area: 'Dataminer', program: 'Reports', url: '/dataminer/admin/reports', seq: 2
    add_program_function 'Grid Admin', functional_area: 'Dataminer', program: 'Reports', url: '/dataminer/admin/grids', seq: 3, restricted: true
    add_program_function 'Prepared Reports', functional_area: 'Dataminer', program: 'Reports', url: '/dataminer/prepared_reports/list', seq: 4
    add_program_function 'ALL Prepared Reports', functional_area: 'Dataminer', program: 'Reports', url: '/dataminer/prepared_reports/list_all', seq: 5, restricted: true
  end

  down do
    drop_functional_area 'Dataminer'
  end
end
