Crossbeams::MenuMigrations::Migrator.migration('Framework') do
  up do
    add_program_function 'New Sales Return', functional_area: 'Pack Material', program: 'Dispatch', group: 'Sales Returns', url: '/pack_material/sales_returns/mr_sales_returns/new'
    add_program_function 'Sales Returns', functional_area: 'Pack Material', program: 'Dispatch', group: 'Sales Returns', url: '/list/mr_sales_returns/with_params?key=incomplete', seq: 2
    add_program_function 'Completed Sales Returns', functional_area: 'Pack Material', program: 'Dispatch', group: 'Sales Returns', url: '/list/mr_sales_returns/with_params?key=completed', seq: 3
  end

  down do
    drop_program_function 'New Sales Return', functional_area: 'Pack Material', program: 'Dispatch'
    drop_program_function 'Sales Returns', functional_area: 'Pack Material', program: 'Dispatch'
    drop_program_function 'Completed Sales Returns', functional_area: 'Pack Material', program: 'Dispatch'
  end
end
