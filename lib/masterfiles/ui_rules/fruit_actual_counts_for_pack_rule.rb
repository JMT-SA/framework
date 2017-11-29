# frozen_string_literal: true

module UiRules
  class FruitActualCountsForPack < Base
    def generate_rules
      @this_repo = FruitActualCountsForPackRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'fruit_actual_counts_for_pack'
    end

    def set_show_fields
      std_fruit_size_count_id_label = StdFruitSizeCountRepo.new.find(@form_object.std_fruit_size_count_id)&.size_count_description
      basic_pack_code_id_label = BasicPackCodeRepo.new.find(@form_object.basic_pack_code_id)&.basic_pack_code
      standard_pack_code_id_label = StandardPackCodeRepo.new.find(@form_object.standard_pack_code_id)&.standard_pack_code
      fields[:std_fruit_size_count_id] = { renderer: :label, with_value: std_fruit_size_count_id_label }
      fields[:basic_pack_code_id] = { renderer: :label, with_value: basic_pack_code_id_label }
      fields[:standard_pack_code_id] = { renderer: :label, with_value: standard_pack_code_id_label }
      fields[:actual_count_for_pack] = { renderer: :label }
      fields[:size_count_variation] = { renderer: :label }
    end

    def common_fields
      {
        std_fruit_size_count_id: { renderer: :select, options: StdFruitSizeCountRepo.new.for_select },
        basic_pack_code_id: { renderer: :select, options: BasicPackCodeRepo.new.for_select },
        standard_pack_code_id: { renderer: :select, options: StandardPackCodeRepo.new.for_select },
        actual_count_for_pack: {},
        size_count_variation: {}
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @this_repo.find(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(std_fruit_size_count_id: nil,
                                    basic_pack_code_id: nil,
                                    standard_pack_code_id: nil,
                                    actual_count_for_pack: nil,
                                    size_count_variation: nil)
    end
  end
end
