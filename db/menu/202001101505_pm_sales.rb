Crossbeams::MenuMigrations::Migrator.migration('Framework') do
  up do
    add_program_function 'New Sales Order', functional_area: 'Pack Material', program: 'Dispatch', group: 'Sales', url: '/pack_material/sales/mr_sales_orders/new'
    add_program_function 'Sales Orders', functional_area: 'Pack Material', program: 'Dispatch', group: 'Sales', url: '/list/mr_sales_orders/with_params?key=unshipped', seq: 2
    add_program_function 'Shipped Sales Orders', functional_area: 'Pack Material', program: 'Dispatch', group: 'Sales', url: '/list/mr_sales_orders/with_params?key=shipped', seq: 3
  end

  down do
    drop_program_function 'New Sales Order', functional_area: 'Pack Material', program: 'Dispatch'
    drop_program_function 'Sales Orders', functional_area: 'Pack Material', program: 'Dispatch'
    drop_program_function 'Shipped Sales Orders', functional_area: 'Pack Material', program: 'Dispatch'
  end
end
