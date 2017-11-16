require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:target_market_group_types, ignore_index_errors: true) do
      primary_key :id
      String :target_market_group_type_code, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
    pgt_created_at(:target_market_group_types, :created_at, function_name: :target_market_group_types_set_created_at, trigger_name: :set_created_at)
    pgt_updated_at(:target_market_group_types, :updated_at, function_name: :target_market_group_types_set_updated_at, trigger_name: :set_updated_at)

    create_table(:target_market_groups, ignore_index_errors: true) do
      primary_key :id
      foreign_key :target_market_group_type_id, :target_market_group_types, null: false, key: [:id]
      String :target_market_group_name, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      unique [:target_market_group_name, :target_market_group_type_id]
      index [:target_market_group_type_id], name: :fki_target_market_groups_target_market_group_types
    end
    pgt_created_at(:target_market_groups, :created_at, function_name: :target_market_groups_set_created_at, trigger_name: :set_created_at)
    pgt_updated_at(:target_market_groups, :updated_at, function_name: :target_market_groups_set_updated_at, trigger_name: :set_updated_at)

    create_table(:target_markets, ignore_index_errors: true) do
      primary_key :id
      String :target_market_name, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
    pgt_created_at(:target_markets, :created_at, function_name: :target_markets_set_created_at, trigger_name: :set_created_at)
    pgt_updated_at(:target_markets, :updated_at, function_name: :target_markets_set_updated_at, trigger_name: :set_updated_at)

    create_table(:target_markets_for_groups, ignore_index_errors: true) do
      primary_key :id
      foreign_key :target_market_id, :target_markets, null: false, key: [:id]
      foreign_key :target_market_group_id, :target_market_groups, null: false, key: [:id]

      unique [:target_market_id, :target_market_group_id]
      index [:target_market_id], name: :fki_target_market_for_groups_target_markets
      index [:target_market_group_id], name: :fki_target_market_for_groups_target_market_groups
    end

    create_table(:destination_regions, ignore_index_errors: true) do
      primary_key :id
      String :destination_region_name, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
    pgt_created_at(:destination_regions, :created_at, function_name: :destination_regions_set_created_at, trigger_name: :set_created_at)
    pgt_updated_at(:destination_regions, :updated_at, function_name: :destination_regions_set_updated_at, trigger_name: :set_updated_at)

    create_table(:destination_countries, ignore_index_errors: true) do
      primary_key :id
      foreign_key :destination_region_id, :destination_regions, null: false, key: [:id]
      String :country_name, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false
      index [:destination_region_id], name: :fki_destination_countries_destination_regions
    end
    pgt_created_at(:destination_countries, :created_at, function_name: :destination_countries_set_created_at, trigger_name: :set_created_at)
    pgt_updated_at(:destination_countries, :updated_at, function_name: :destination_countries_set_updated_at, trigger_name: :set_updated_at)

    create_table(:destination_cities, ignore_index_errors: true) do
      primary_key :id
      foreign_key :destination_country_id, :destination_countries, null: false, key: [:id]
      String :city_name, null: false

      DateTime :updated_at, null: false
      DateTime :created_at, null: false

      unique [:city_name, :destination_country_id]
      index [:destination_country_id], name: :fki_destination_cities_destination_countries
    end
    pgt_created_at(:destination_cities, :created_at, function_name: :destination_cities_set_created_at, trigger_name: :set_created_at)
    pgt_updated_at(:destination_cities, :updated_at, function_name: :destination_cities_set_updated_at, trigger_name: :set_updated_at)

    create_table(:target_markets_for_countries, ignore_index_errors: true) do
      primary_key :id
      foreign_key :target_market_id, :target_markets, null: false, key: [:id]
      foreign_key :destination_country_id, :destination_countries, null: false, key: [:id]

      unique [:target_market_id, :destination_country_id]
      index [:target_market_id], name: :fki_target_markets_for_countries_target_markets
      index [:destination_country_id], name: :fki_target_markets_for_countries_destination_countries
    end
  end

  down do
    drop_table(:target_markets_for_countries)

    drop_trigger(:destination_cities, :set_created_at)
    drop_function(:destination_cities_set_created_at)
    drop_trigger(:destination_cities, :set_updated_at)
    drop_function(:destination_cities_set_updated_at)
    drop_table(:destination_cities)

    drop_trigger(:destination_countries, :set_created_at)
    drop_function(:destination_countries_set_created_at)
    drop_trigger(:destination_countries, :set_updated_at)
    drop_function(:destination_countries_set_updated_at)
    drop_table(:destination_countries)

    drop_trigger(:destination_regions, :set_created_at)
    drop_function(:destination_regions_set_created_at)
    drop_trigger(:destination_regions, :set_updated_at)
    drop_function(:destination_regions_set_updated_at)
    drop_table(:destination_regions)

    drop_table(:target_markets_for_groups)

    drop_trigger(:target_markets, :set_created_at)
    drop_function(:target_markets_set_created_at)
    drop_trigger(:target_markets, :set_updated_at)
    drop_function(:target_markets_set_updated_at)
    drop_table(:target_markets)

    drop_trigger(:target_market_groups, :set_created_at)
    drop_function(:target_market_groups_set_created_at)
    drop_trigger(:target_market_groups, :set_updated_at)
    drop_function(:target_market_groups_set_updated_at)
    drop_table(:target_market_groups)

    drop_trigger(:target_market_group_types, :set_created_at)
    drop_function(:target_market_group_types_set_created_at)
    drop_trigger(:target_market_group_types, :set_updated_at)
    drop_function(:target_market_group_types_set_updated_at)
    drop_table(:target_market_group_types)
  end
end
