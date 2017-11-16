require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:std_fruit_size_counts, ignore_index_errors: true) do
      primary_key :id
      foreign_key :commodity_id, :commodities, null: false, key: [:id]
      String :size_count_description
      String :marketing_size_range_mm
      String :marketing_weight_range
      String :size_count_interval_group
      Integer :size_count_value, null: false
      Integer :minimum_size_mm
      Integer :maximum_size_mm
      Integer :average_size_mm
      Float :minimum_weight_gm
      Float :maximum_weight_gm
      Float :average_weight_gm

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      unique [:commodity_id, :size_count_value]
      index [:commodity_id], name: :fki_std_fruit_size_counts_commodities
    end
    pgt_created_at(:std_fruit_size_counts, :created_at, function_name: :std_fruit_size_counts_set_created_at, trigger_name: :set_created_at)
    pgt_updated_at(:std_fruit_size_counts, :updated_at, function_name: :std_fruit_size_counts_set_updated_at, trigger_name: :set_updated_at)

    create_table(:basic_pack_codes, ignore_index_errors: true) do
      primary_key :id
      String :basic_pack_code, null: false
      String :description
      Integer :length_mm
      Integer :width_mm
      Integer :height_mm

      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
    pgt_created_at(:basic_pack_codes, :created_at, function_name: :basic_pack_codes_set_created_at, trigger_name: :set_created_at)
    pgt_updated_at(:basic_pack_codes, :updated_at, function_name: :basic_pack_codes_set_updated_at, trigger_name: :set_updated_at)

    create_table(:standard_pack_codes, ignore_index_errors: true) do
      primary_key :id
      String :standard_pack_code, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
    pgt_created_at(:standard_pack_codes, :created_at, function_name: :standard_pack_codes_set_created_at, trigger_name: :set_created_at)
    pgt_updated_at(:standard_pack_codes, :updated_at, function_name: :standard_pack_codes_set_updated_at, trigger_name: :set_updated_at)

    create_table(:fruit_actual_counts_for_packs, ignore_index_errors: true) do
      primary_key :id
      foreign_key :std_fruit_size_count_id, :std_fruit_size_counts, null: false, key: [:id]
      foreign_key :basic_pack_code_id, :basic_pack_codes, null: false, key: [:id]
      foreign_key :standard_pack_code_id, :standard_pack_codes, null: false, key: [:id]

      Integer :actual_count_for_pack, null: false
      String :size_count_variation, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      unique [:std_fruit_size_count_id, :basic_pack_code_id, :size_count_variation]
      index [:std_fruit_size_count_id], name: :fki_fruit_actual_counts_for_packs_std_fruit_size_counts
      index [:basic_pack_code_id], name: :fki_fruit_actual_counts_for_packs_basic_pack_codes
      index [:standard_pack_code_id], name: :fki_fruit_actual_counts_for_packs_standard_pack_codes
    end
    pgt_created_at(:fruit_actual_counts_for_packs, :created_at, function_name: :fruit_actual_counts_for_packs_set_created_at, trigger_name: :set_created_at)
    pgt_updated_at(:fruit_actual_counts_for_packs, :updated_at, function_name: :fruit_actual_counts_for_packs_set_updated_at, trigger_name: :set_updated_at)

    create_table(:fruit_size_references, ignore_index_errors: true) do
      primary_key :id
      foreign_key :fruit_actual_counts_for_pack_id, :fruit_actual_counts_for_packs, null: false, key: [:id]
      String :size_reference, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      unique [:fruit_actual_counts_for_pack_id, :size_reference]
      index [:fruit_actual_counts_for_pack_id], name: :fruit_size_references_fruit_actual_counts_for_packs
    end
    pgt_created_at(:fruit_size_references, :created_at, function_name: :fruit_size_references_set_created_at, trigger_name: :set_created_at)
    pgt_updated_at(:fruit_size_references, :updated_at, function_name: :fruit_size_references_set_updated_at, trigger_name: :set_updated_at)
  end

  down do
    drop_trigger(:fruit_size_references, :set_created_at)
    drop_function(:fruit_size_references_set_created_at)
    drop_trigger(:fruit_size_references, :set_updated_at)
    drop_function(:fruit_size_references_set_updated_at)
    drop_table(:fruit_size_references)

    drop_trigger(:fruit_actual_counts_for_packs, :set_created_at)
    drop_function(:fruit_actual_counts_for_packs_set_created_at)
    drop_trigger(:fruit_actual_counts_for_packs, :set_updated_at)
    drop_function(:fruit_actual_counts_for_packs_set_updated_at)
    drop_table(:fruit_actual_counts_for_packs)

    drop_trigger(:standard_pack_codes, :set_created_at)
    drop_function(:standard_pack_codes_set_created_at)
    drop_trigger(:standard_pack_codes, :set_updated_at)
    drop_function(:standard_pack_codes_set_updated_at)
    drop_table(:standard_pack_codes)

    drop_trigger(:basic_pack_codes, :set_created_at)
    drop_function(:basic_pack_codes_set_created_at)
    drop_trigger(:basic_pack_codes, :set_updated_at)
    drop_function(:basic_pack_codes_set_updated_at)
    drop_table(:basic_pack_codes)

    drop_trigger(:std_fruit_size_counts, :set_created_at)
    drop_function(:std_fruit_size_counts_set_created_at)
    drop_trigger(:std_fruit_size_counts, :set_updated_at)
    drop_function(:std_fruit_size_counts_set_updated_at)
    drop_table(:std_fruit_size_counts)
  end
end
