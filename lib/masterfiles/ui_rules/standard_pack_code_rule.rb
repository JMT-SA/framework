# frozen_string_literal: true

module UiRules
  class StandardPackCodeRule < Base
    def generate_rules
      @this_repo = MasterfilesApp::FruitSizeRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'standard_pack_code'
    end

    def set_show_fields
      fields[:standard_pack_code] = { renderer: :label }
    end

    def common_fields
      {
        standard_pack_code: { required: true }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @this_repo.find_standard_pack_code(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(standard_pack_code: nil)
    end
  end
end
