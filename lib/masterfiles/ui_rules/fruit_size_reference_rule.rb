# frozen_string_literal: true

module UiRules
  class FruitSizeReferenceRule < Base
    def generate_rules
      @this_repo = FruitSizeRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'fruit_size_reference'
    end

    def set_show_fields
      fruit_actual_counts_for_pack_id_label = FruitSizeRepo.new.find_fruit_actual_counts_for_pack(@form_object.fruit_actual_counts_for_pack_id)&.size_count_variation
      fields[:fruit_actual_counts_for_pack_id] = { renderer: :label, with_value: fruit_actual_counts_for_pack_id_label }
      fields[:size_reference] = { renderer: :label }
    end

    def common_fields
      {
        fruit_actual_counts_for_pack_id: { renderer: :select, options: FruitSizeRepo.new.for_select_fruit_actual_counts_for_packs },
        size_reference: {}
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @this_repo.find_fruit_size_reference(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(fruit_actual_counts_for_pack_id: nil,
                                    size_reference: nil)
    end
  end
end
