# frozen_string_literal: true

module UiRules
  class BasicPackCodeRule < Base
    def generate_rules
      @this_repo = FruitSizeRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'basic_pack_code'
    end

    def set_show_fields
      fields[:basic_pack_code] = { renderer: :label }
      fields[:description] = { renderer: :label }
      fields[:length_mm] = { renderer: :label }
      fields[:width_mm] = { renderer: :label }
      fields[:height_mm] = { renderer: :label }
    end

    def common_fields
      {
        basic_pack_code: {},
        description: {},
        length_mm: {},
        width_mm: {},
        height_mm: {}
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @this_repo.find_basic_pack_code(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(basic_pack_code: nil,
                                    description: nil,
                                    length_mm: nil,
                                    width_mm: nil,
                                    height_mm: nil)
    end
  end
end
