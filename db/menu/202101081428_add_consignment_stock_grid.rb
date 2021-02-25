Crossbeams::MenuMigrations::Migrator.migration('Framework') do
  up do
    add_program_function 'Consignment Stock', functional_area: 'Pack Material', program: 'Transactions', url: '/list/consignment_stock'
  end

  down do
    drop_program_function 'Consignment Stock', functional_area: 'Pack Material', program: 'Transactions'
  end
end
