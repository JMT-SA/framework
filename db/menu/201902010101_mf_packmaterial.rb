Crossbeams::MenuMigrations::Migrator.migration('Framework') do
  up do
    add_program 'Pack Material', functional_area: 'Masterfiles'
    add_program_function 'Cost Types', functional_area: 'Masterfiles', program: 'Pack Material', url: '/list/mr_cost_types'
  end

  down do
    drop_program 'Pack Material', functional_area: 'Masterfiles'
  end
end
