# frozen_string_literal: true

module UiRules
  class MatresSubTypeRule < Base
    def generate_rules
      @repo = PackMaterialApp::ConfigRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show
      set_config_fields if @mode == :config

      form_name 'matres_sub_type'
    end

    def set_show_fields
      material_resource_type_id_label = @repo.find_matres_type(@form_object.material_resource_type_id)&.type_name
      fields[:material_resource_type_id] = { renderer: :label, with_value: material_resource_type_id_label, caption: 'Type' }
      fields[:sub_type_name] = { renderer: :label }
      fields[:short_code] = { renderer: :label }
      fields[:internal_seq] = { renderer: :label }
    end

    def set_config_fields
      fields[:product_code_separator] = { renderer: :label }
      fields[:has_suppliers] = { renderer: :checkbox }
      fields[:has_marketers] = { renderer: :checkbox }
      fields[:has_retailers] = { renderer: :checkbox }
      fields[:active] = { renderer: :checkbox }
    end

    def common_fields
      {
        material_resource_type_id: { renderer: :select, options: @repo.for_select_matres_types, caption: 'Type' },
        sub_type_name: {},
        short_code: { required: true, force_uppercase: true }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_matres_sub_type(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(material_resource_type_id: nil,
                                    sub_type_name: nil)
    end
  end
end
