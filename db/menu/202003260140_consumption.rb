Crossbeams::MenuMigrations::Migrator.migration('Framework') do
  up do
    drop_program_function 'Bulk Stock Adjustments', functional_area: 'Pack Material', program: 'Transactions'

    add_program 'Adjustments', functional_area: 'Pack Material', seq: 6
    add_program_function 'Bulk Stock Adjustments', functional_area: 'Pack Material', program: 'Adjustments', url: '/list/mr_bulk_stock_adjustments/with_params?key=standard', seq: 1, group: 'Bulk Stock Adjustments'
    add_program_function 'List Completed', functional_area: 'Pack Material', program: 'Adjustments', url: '/list/mr_bulk_stock_adjustments/with_params?key=completed', seq: 2, group: 'Bulk Stock Adjustments'
    add_program_function 'Staging', functional_area: 'Pack Material', program: 'Adjustments', url: '/list/mr_bulk_stock_adjustments/with_params?key=staging_consumption', seq: 3, group: 'Consumption'
    add_program_function 'Carton Assembly', functional_area: 'Pack Material', program: 'Adjustments', url: '/list/mr_bulk_stock_adjustments/with_params?key=carton_assembly', seq: 4, group: 'Consumption'
    add_program_function 'Staging Completed', functional_area: 'Pack Material', program: 'Adjustments', url: '/list/mr_bulk_stock_adjustments/with_params?key=staging_completed', seq: 5, group: 'Consumption'
    add_program_function 'Carton Assembly Completed', functional_area: 'Pack Material', program: 'Adjustments', url: '/list/mr_bulk_stock_adjustments/with_params?key=carton_completed', seq: 6, group: 'Consumption'
  end

  down do
    drop_program 'Adjustments', functional_area: 'Pack Material'
  end
end
