Crossbeams::MenuMigrations::Migrator.migration('Framework') do
  up do
    add_functional_area 'Label Designer'
    add_program 'Designs', functional_area: 'Label Designer'
    add_program_function 'Available printers', functional_area: 'Label Designer', program: 'Designs', url: '/list/printers', seq: 3
    add_program_function 'Printer applications', functional_area: 'Label Designer', program: 'Designs', url: '/list/printer_applications', seq: 4
  end

  down do
    drop_functional_area 'Label Designer'
  end
end
