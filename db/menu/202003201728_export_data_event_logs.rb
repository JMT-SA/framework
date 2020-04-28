Crossbeams::MenuMigrations::Migrator.migration('Nspack') do
  up do
    add_program_function 'Export data event logs', functional_area: 'Development', program: 'Logging', url: '/list/export_data_event_logs', seq: 2
  end

  down do
    drop_program_function 'Export data event logs', functional_area: 'Development', program: 'Logging'
  end
end
