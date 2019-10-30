Crossbeams::MenuMigrations::Migrator.migration('Framework') do
  up do
    add_functional_area 'RMD', rmd_menu: true
    add_program 'Home', functional_area: 'RMD'
    add_program_function 'Menu', functional_area: 'RMD', program: 'Home', url: '/rmd/home'

    add_program 'Utilities', functional_area: 'RMD'
    add_program_function 'Check Barcodes', functional_area: 'RMD', program: 'Utilities', url: '/rmd/utilities/check_barcode'
    add_program_function 'Toggle Camera Scan', functional_area: 'RMD', program: 'Utilities', url: '/rmd/utilities/toggle_camera', seq: 2
  end

  down do
    drop_functional_area 'RMD'
  end
end
