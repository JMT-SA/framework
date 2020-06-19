Crossbeams::MenuMigrations::Migrator.migration('Framework') do
  up do
    add_program_function 'Weighted Averages', functional_area: 'Pack Material', program: 'Transactions', url: '/pack_material/transactions/weighted_averages/show', seq: 8, group: 'Weighted Averages'
  end

  down do
    drop_program_function 'Weighted Averages', functional_area: 'Pack Material', program: 'Transactions'
  end
end
