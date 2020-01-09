Crossbeams::MenuMigrations::Migrator.migration('Framework') do
  up do
    add_program 'Printing', functional_area: 'RMD', seq: 4
    add_program_function 'SKU Label', functional_area: 'RMD', program: 'Printing', url: '/rmd/printing/sku_label/new'
  end

  down do
    drop_program 'Printing', functional_area: 'RMD'
  end
end
