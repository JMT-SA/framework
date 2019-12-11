Crossbeams::MenuMigrations::Migrator.migration('Framework') do
  up do
    add_program 'Target Markets', functional_area: 'Masterfiles', seq: 3
    add_program_function 'Group Types', functional_area: 'Masterfiles', program: 'Target Markets', url: '/list/target_market_group_types', group: 'Target Markets'
    add_program_function 'Groups', functional_area: 'Masterfiles', program: 'Target Markets', url: '/list/target_market_groups', group: 'Target Markets', seq: 2
    add_program_function 'Target Markets', functional_area: 'Masterfiles', program: 'Target Markets', url: '/list/target_markets', group: 'Target Markets', seq: 3
    add_program_function 'Regions', functional_area: 'Masterfiles', program: 'Target Markets', url: '/list/destination_regions', group: 'Destination', seq: 4
    add_program_function 'Countries', functional_area: 'Masterfiles', program: 'Target Markets', url: '/list/destination_countries', group: 'Destination', seq: 5
    add_program_function 'Cities', functional_area: 'Masterfiles', program: 'Target Markets', url: '/list/destination_cities', group: 'Destination', seq: 6
  end

  down do
    drop_program 'Target Markets', functional_area: 'Masterfiles'
  end
end
