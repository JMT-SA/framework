require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:cultivar_groups, ignore_index_errors: true) do
      primary_key :id
      String :cultivar_group_code, null: false
      String :description

      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
    pgt_created_at(:cultivar_groups, :created_at, function_name: :cultivar_groups_set_created_at, trigger_name: :set_created_at)
    pgt_updated_at(:cultivar_groups, :updated_at, function_name: :cultivar_groups_set_updated_at, trigger_name: :set_updated_at)

    create_table(:cultivars, ignore_index_errors: true) do
      primary_key :id
      foreign_key :commodity_id, :commodities, null: false, key: [:id]
      foreign_key :cultivar_group_id, :cultivar_groups, key: [:id]

      String :cultivar_name, null: false
      String :description

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      unique [:cultivar_name, :commodity_id]
      index [:commodity_id], name: :fki_cultivars_commodities
      index [:cultivar_group_id], name: :fki_cultivars_cultivar_group_id
    end
    pgt_created_at(:cultivars, :created_at, function_name: :cultivars_set_created_at, trigger_name: :set_created_at)
    pgt_updated_at(:cultivars, :updated_at, function_name: :cultivars_set_updated_at, trigger_name: :set_updated_at)


    create_table(:marketing_varieties, ignore_index_errors: true) do
      primary_key :id
      String :marketing_variety_code, null: false
      String :description

      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
    pgt_created_at(:marketing_varieties, :created_at, function_name: :marketing_varieties_set_created_at, trigger_name: :set_created_at)
    pgt_updated_at(:marketing_varieties, :updated_at, function_name: :marketing_varieties_set_updated_at, trigger_name: :set_updated_at)


    create_table(:marketing_varieties_for_cultivars, ignore_index_errors: true) do
      primary_key :id
      foreign_key :cultivar_id, :cultivars, null: false, key: [:id]
      foreign_key :marketing_variety_id, :marketing_varieties, null: false, key: [:id]

      unique [:cultivar_id, :marketing_variety_id]
      index [:cultivar_id], name: :fki_marketing_varieties_for_cultivars_cultivars
      index [:marketing_variety_id], name: :fki_marketing_varieties_for_cultivars_marketing_varieties
    end
  end

  down do
    drop_table(:marketing_varieties_for_cultivars)

    drop_trigger(:marketing_varieties, :set_created_at)
    drop_function(:marketing_varieties_set_created_at)
    drop_trigger(:marketing_varieties, :set_updated_at)
    drop_function(:marketing_varieties_set_updated_at)
    drop_table(:marketing_varieties)

    drop_trigger(:cultivars, :set_created_at)
    drop_function(:cultivars_set_created_at)
    drop_trigger(:cultivars, :set_updated_at)
    drop_function(:cultivars_set_updated_at)
    drop_table(:cultivars)

    drop_trigger(:cultivar_groups, :set_created_at)
    drop_function(:cultivar_groups_set_created_at)
    drop_trigger(:cultivar_groups, :set_updated_at)
    drop_function(:cultivar_groups_set_updated_at)
    drop_table(:cultivar_groups)
  end
end
