Crossbeams::MenuMigrations::Migrator.migration('Framework') do
  up do
    add_program 'General', functional_area: 'Masterfiles'
    add_program_function 'UOM Types', functional_area: 'Masterfiles', program: 'General', url: '/list/uom_types', group: 'Units of Measure'
    add_program_function 'UOMs', functional_area: 'Masterfiles', program: 'General', url: '/list/uoms', seq: 2, group: 'Units of Measure'
  end

  down do
    drop_program 'General', functional_area: 'Masterfiles'
  end
end
