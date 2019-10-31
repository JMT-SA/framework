Crossbeams::MenuMigrations::Migrator.migration('Framework') do
  up do
    add_program 'Deliveries', functional_area: 'RMD', seq: 2
    add_program_function 'Putaway', functional_area: 'RMD', program: 'Deliveries', url: '/rmd/deliveries/putaways/new'
    add_program_function 'Delivery status', functional_area: 'RMD', program: 'Deliveries', url: '/rmd/deliveries/status', seq: 2

    add_program 'Vehicle', functional_area: 'RMD', seq: 3
    add_program_function 'Load', functional_area: 'RMD', program: 'Vehicle', url: '/rmd/vehicles/load/new'
    add_program_function 'Offload', functional_area: 'RMD', program: 'Vehicle', url: '/rmd/vehicles/offload/new', seq: 2

    add_program 'Stock', functional_area: 'RMD', seq: 4
    add_program_function 'Adjust Item', functional_area: 'RMD', program: 'Stock', url: '/rmd/stock_adjustments/adjust_item/new'
    add_program_function 'Move', functional_area: 'RMD', program: 'Stock', url: '/rmd/stock/moves/new', seq: 2
  end

  down do
    drop_program 'Deliveries', functional_area: 'RMD'
    drop_program 'Vehicle', functional_area: 'RMD'
    drop_program 'Stock', functional_area: 'RMD'
  end
end
