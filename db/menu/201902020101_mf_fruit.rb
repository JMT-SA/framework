Crossbeams::MenuMigrations::Migrator.migration('Framework') do
  up do
    add_program 'Fruit', functional_area: 'Masterfiles', seq: 2
    add_program_function 'Groups', functional_area: 'Masterfiles', program: 'Fruit', url: '/list/commodity_groups', group: 'Commodities'
    add_program_function 'Commodities', functional_area: 'Masterfiles', program: 'Fruit', url: '/list/commodities', seq: 2, group: 'Commodities'
    add_program_function 'Groups', functional_area: 'Masterfiles', program: 'Fruit', url: '/list/cultivar_groups', seq: 3, group: 'Cultivars'
    add_program_function 'Cultivars', functional_area: 'Masterfiles', program: 'Fruit', url: '/list/cultivars', seq: 4, group: 'Cultivars'
    add_program_function 'Marketing Varieties', functional_area: 'Masterfiles', program: 'Fruit', url: '/list/marketing_varieties', seq: 5, group: 'Cultivars'
    add_program_function 'Basic', functional_area: 'Masterfiles', program: 'Fruit', url: '/list/basic_pack_codes', seq: 6, group: 'Pack codes'
    add_program_function 'Standard', functional_area: 'Masterfiles', program: 'Fruit', url: '/list/standard_pack_codes', seq: 7, group: 'Pack codes'
    add_program_function 'Std Fruit Size Counts', functional_area: 'Masterfiles', program: 'Fruit', url: '/list/std_fruit_size_counts', seq: 8
  end

  down do
    drop_program 'Fruit', functional_area: 'Masterfiles'
  end
end
