# frozen_string_literal: true

module UiRules
  class FruitActualCountsForPackRule < Base
    def generate_rules
      @this_repo = MasterfilesApp::FruitSizeRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'fruit_actual_counts_for_pack'
    end

    def set_show_fields
      std_fruit_size_count_id_label = MasterfilesApp::FruitSizeRepo.new.find_std_fruit_size_count(@form_object.std_fruit_size_count_id)&.size_count_description
      basic_pack_code_id_label = MasterfilesApp::FruitSizeRepo.new.find_basic_pack_code(@form_object.basic_pack_code_id)&.basic_pack_code
      standard_pack_code_id_label = MasterfilesApp::FruitSizeRepo.new.find_standard_pack_code(@form_object.standard_pack_code_id)&.standard_pack_code
      fields[:std_fruit_size_count_id] = { renderer: :label, with_value: std_fruit_size_count_id_label }
      fields[:basic_pack_code_id] = { renderer: :label, with_value: basic_pack_code_id_label }
      fields[:standard_pack_code_id] = { renderer: :label, with_value: standard_pack_code_id_label }
      fields[:actual_count_for_pack] = { renderer: :label }
      fields[:size_count_variation] = { renderer: :label }
    end

    def common_fields
      {
        std_fruit_size_count_id: { renderer: :select, options: MasterfilesApp::FruitSizeRepo.new.for_select_std_fruit_size_counts },
        basic_pack_code_id: { renderer: :select, options: MasterfilesApp::FruitSizeRepo.new.for_select_basic_pack_codes, required: true  },
        standard_pack_code_id: { renderer: :select, options: MasterfilesApp::FruitSizeRepo.new.for_select_standard_pack_codes, required: true  },
        actual_count_for_pack: { required: true },
        size_count_variation: { required: true }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @this_repo.find_fruit_actual_counts_for_pack(@options[:id])
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
