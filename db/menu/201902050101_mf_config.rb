Crossbeams::MenuMigrations::Migrator.migration('Framework') do
  up do
    add_program 'Config', functional_area: 'Masterfiles'
    add_program_function 'Label Templates', functional_area: 'Masterfiles', program: 'Config', url: '/list/label_templates'
  end

  down do
    drop_program 'Config', functional_area: 'Masterfiles'
  end
end
