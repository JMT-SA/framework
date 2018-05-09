# frozen_string_literal: true

module MasterfilesApp
  class FruitSizeRepo < BaseRepo
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

    def delete_basic_pack_code(id)
      dependents = DB[:fruit_actual_counts_for_packs].where(basic_pack_code_id: id).select_map(:id)
      return { error: 'This pack code is in use.' } unless dependents.empty?
      DB[:basic_pack_codes].where(id: id).delete
      { success: true }
    end

    def delete_standard_pack_code(id)
      dependents = DB[:fruit_actual_counts_for_packs].where(standard_pack_code_id: id).select_map(:id)
      return { error: 'This pack code is in use.' } unless dependents.empty?
      DB[:standard_pack_codes].where(id: id).delete
      { success: true }
    end

    def delete_std_fruit_size_count(id)
      actual_counts_collection = DB[:fruit_actual_counts_for_packs].where(std_fruit_size_count_id: id)
      actual_counts_collection.select_map(:id).each do |act_count_id|
        DB[:fruit_size_references].where(fruit_actual_counts_for_pack_id: act_count_id).delete
      end
      actual_counts_collection.delete
      DB[:std_fruit_size_counts].where(id: id).delete
    end

    def delete_fruit_actual_counts_for_pack(id)
      DB[:fruit_size_references].where(fruit_actual_counts_for_pack_id: id).delete
      DB[:fruit_actual_counts_for_packs].where(id: id).delete
    end
  end
end