# frozen_string_literal: true

module UiRules
  class UomRule < Base
    def generate_rules
      @repo = MasterfilesApp::GeneralRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show
      form_name 'uom'
    end

    def set_show_fields
      uom_type_id_label = @repo.find_uom_type(@form_object.uom_type_id)&.code
      fields[:uom_type_id] = { renderer: :label, with_value: uom_type_id_label, caption: 'UOM Type' }
      fields[:uom_code] = { renderer: :label, caption: 'UOM Code' }
    end

    def common_fields
      {
        uom_type_id: { renderer: :select, options: @repo.for_select_uom_types, caption: 'UOM Type', required: true },
        uom_code: { required: true, caption: 'UOM Code' }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_uom(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(uom_type_id: nil,
                                    uom_code: nil)
    end
  end
end
