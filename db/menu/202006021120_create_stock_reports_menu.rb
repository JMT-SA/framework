Crossbeams::MenuMigrations::Migrator.migration('Framework') do
  up do
    add_program_function 'Stock Movement Report', functional_area: 'Pack Material', program: 'Transactions', url: '/pack_material/transactions/movement_report/new', seq: 8, group: 'Movement Report'
  end

  down do
    drop_program_function 'Stock Movement Report', functional_area: 'Pack Material', program: 'Transactions'
  end
end
