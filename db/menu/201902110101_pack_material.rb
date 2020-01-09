Crossbeams::MenuMigrations::Migrator.migration('Framework') do
  up do
    add_functional_area 'Pack Material'
    add_program 'Configuration', functional_area: 'Pack Material', seq: 1
    add_program_function 'Types', functional_area: 'Pack Material', program: 'Configuration', url: '/list/material_resource_types'
    add_program_function 'Sub Types', functional_area: 'Pack Material', program: 'Configuration', url: '/list/material_resource_sub_types', seq: 2
    add_program_function 'Products', functional_area: 'Pack Material', program: 'Configuration', url: '/list/pack_material_products', seq: 3
    add_program_function 'Product codes', functional_area: 'Pack Material', program: 'Configuration', url: '/list/pack_material_product_variants', seq: 4

    add_program 'Replenish', functional_area: 'Pack Material', seq: 2
    add_program_function 'New Purchase Order', functional_area: 'Pack Material', program: 'Replenish', url: '/pack_material/replenish/mr_purchase_orders/preselect', group: 'Purchase Order'
    add_program_function 'Purchase Orders', functional_area: 'Pack Material', program: 'Replenish', url: '/list/mr_purchase_orders/with_params?key=incomplete', seq: 2, group: 'Purchase Order'
    add_program_function 'Completed Purchase Orders', functional_area: 'Pack Material', program: 'Replenish', url: '/list/mr_purchase_orders/with_params?key=completed', seq: 3, group: 'Purchase Order'
    add_program_function 'New Delivery', functional_area: 'Pack Material', program: 'Replenish', url: '/pack_material/replenish/mr_deliveries/new', seq: 4, group: 'Deliveries'
    add_program_function 'Deliveries', functional_area: 'Pack Material', program: 'Replenish', url: '/list/mr_deliveries/with_params?key=incomplete', seq: 5, group: 'Deliveries'
    add_program_function 'Completed Deliveries', functional_area: 'Pack Material', program: 'Replenish', url: '/list/mr_deliveries/with_params?key=completed', seq: 6, group: 'Deliveries'
    add_program_function 'Delivery Terms', functional_area: 'Pack Material', program: 'Replenish', url: '/list/mr_delivery_terms', seq: 7, group: 'Deliveries'
    add_program_function 'SKU Locations', functional_area: 'Pack Material', program: 'Replenish', url: '/list/sku_locations', seq: 8

    # add_program 'Material Resource', functional_area: 'Pack Material' -- defined with underscore, but no progfuncs (used for permission?)

    add_program 'Transactions', functional_area: 'Pack Material', seq: 3
    add_program_function 'SKU Locations', functional_area: 'Pack Material', program: 'Transactions', url: '/list/sku_locations'
    add_program_function 'Search SKU Locations', functional_area: 'Pack Material', program: 'Transactions', url: '/search/sku_locations', seq: 2
    add_program_function 'SKU Transaction History', functional_area: 'Pack Material', program: 'Transactions', url: '/list/sku_transaction_history', seq: 3
    add_program_function 'Bulk Stock Adjustments', functional_area: 'Pack Material', program: 'Transactions', url: '/list/mr_bulk_stock_adjustments', seq: 4
    add_program_function 'Search SKUs', functional_area: 'Pack Material', program: 'Transactions', url: '/search/mr_skus', seq: 5
    add_program_function 'Stock Totals', functional_area: 'Pack Material', program: 'Transactions', url: '/list/stock_totals', seq: 6, group: 'Stock Totals'
    add_program_function 'Search Stock Totals', functional_area: 'Pack Material', program: 'Transactions', url: '/search/stock_totals', seq: 7, group: 'Stock Totals'

    add_program 'Tripsheets', functional_area: 'Pack Material', seq: 4
    add_program_function 'Vehicle Types', functional_area: 'Pack Material', program: 'Tripsheets', url: '/list/vehicle_types'
    add_program_function 'Vehicles', functional_area: 'Pack Material', program: 'Tripsheets', url: '/list/vehicles', seq: 2
    add_program_function 'Tripsheets', functional_area: 'Pack Material', program: 'Tripsheets', url: '/list/vehicle_jobs/with_params?key=incomplete', seq: 3
    add_program_function 'Search Tripsheets', functional_area: 'Pack Material', program: 'Tripsheets', url: '/search/vehicle_jobs', seq: 4
    add_program_function 'Completed Tripsheets', functional_area: 'Pack Material', program: 'Tripsheets', url: '/list/vehicle_jobs/with_params?key=completed', seq: 5

    add_program 'Dispatch', functional_area: 'Pack Material', seq: 5
    add_program_function 'New Return', functional_area: 'Pack Material', program: 'Dispatch', group: 'GRNs', url: '/pack_material/dispatch/mr_goods_returned_notes/new'
    add_program_function 'Returns', functional_area: 'Pack Material', program: 'Dispatch', group: 'GRNs', url: '/list/mr_goods_returned_notes/with_params?key=unshipped', seq: 2
    add_program_function 'Shipped Returns', functional_area: 'Pack Material', program: 'Dispatch', group: 'GRNs', url: '/list/mr_goods_returned_notes/with_params?key=shipped', seq: 3
  end

  down do
    drop_functional_area 'Pack Material'
  end
end
