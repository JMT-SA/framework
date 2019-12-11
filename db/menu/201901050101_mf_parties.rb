Crossbeams::MenuMigrations::Migrator.migration('Framework') do
  up do
    add_functional_area 'Masterfiles'
    add_program 'Parties', functional_area: 'Masterfiles'
    add_program_function 'Addresses', functional_area: 'Masterfiles', program: 'Parties', url: '/list/addresses', group: 'Contact Details'
    add_program_function 'Contact Methods', functional_area: 'Masterfiles', program: 'Parties', url: '/list/contact_methods', group: 'Contact Details', seq: 2
    add_program_function 'Organizations', functional_area: 'Masterfiles', program: 'Parties', url: '/list/organizations', seq: 3
    add_program_function 'People', functional_area: 'Masterfiles', program: 'Parties', url: '/list/people', seq: 4
    add_program_function 'Customer Types', functional_area: 'Masterfiles', program: 'Parties', url: '/list/customer_types', seq: 5
    add_program_function 'Customers', functional_area: 'Masterfiles', program: 'Parties', url: '/list/customers', seq: 6
    add_program_function 'Supplier Types', functional_area: 'Masterfiles', program: 'Parties', url: '/list/supplier_types', seq: 7
    add_program_function 'Suppliers', functional_area: 'Masterfiles', program: 'Parties', url: '/list/suppliers', seq: 8
  end

  down do
    drop_functional_area 'Masterfiles'
  end
end
