Crossbeams::MenuMigrations::Migrator.migration('Framework') do
  up do
    add_program_function 'Account Codes', functional_area: 'Masterfiles', program: 'Pack Material', url: '/list/account_codes'
  end

  down do
    drop_program_function 'Account Codes', functional_area: 'Masterfiles', program: 'Pack Material'
  end
end
