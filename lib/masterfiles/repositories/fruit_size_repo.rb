# frozen_string_literal: true

module MasterfilesApp
  class FruitSizeRepo < RepoBase
    build_for_select :basic_pack_codes,
                     label: :basic_pack_code,
                     value: :id,
                     no_active_check: true,
                     order_by: :basic_pack_code
    build_for_select :standard_pack_codes,
                     label: :standard_pack_code,
                     value: :id,
                     no_active_check: true,
                     order_by: :standard_pack_code
    build_for_select :std_fruit_size_counts,
                     label: :size_count_description,
                     value: :id,
                     no_active_check: true,
                     order_by: :size_count_description
    build_for_select :fruit_actual_counts_for_packs,
                     label: :size_count_variation,
                     value: :id,
                     no_active_check: true,
                     order_by: :size_count_variation
    build_for_select :fruit_size_references,
                     label: :size_reference,
                     value: :id,
                     no_active_check: true,
                     order_by: :size_reference

    crud_calls_for :basic_pack_codes, name: :basic_pack_code, wrapper: BasicPackCode
    crud_calls_for :standard_pack_codes, name: :standard_pack_code, wrapper: StandardPackCode
    crud_calls_for :std_fruit_size_counts, name: :std_fruit_size_count, wrapper: StdFruitSizeCount
    crud_calls_for :fruit_actual_counts_for_packs, name: :fruit_actual_counts_for_pack, wrapper: FruitActualCountsForPack
    crud_calls_for :fruit_size_references, name: :fruit_size_reference, wrapper: FruitSizeReference
  end
end
