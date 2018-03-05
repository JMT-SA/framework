# frozen_string_literal: true

module UiRules
  class MatresSubTypeRule < Base
    def generate_rules
      @this_repo = PackMaterialApp::ConfigRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show
      set_config_fields if @mode == :config

      form_name 'matres_sub_type'
    end

    def set_show_fields
      material_resource_type_id_label = @this_repo.find(:material_resource_types, MatresType, @form_object.material_resource_type_id)&.type_name
      fields[:material_resource_type_id] = { renderer: :label, with_value: material_resource_type_id_label, caption: 'Type' }
      fields[:sub_type_name] = { renderer: :label }
    end

    def set_config_fields
      fields[:material_resource_sub_type_id] = { renderer: :hidden }
      fields[:product_code_separator] = { renderer: :label }
      fields[:has_suppliers] = { renderer: :checkbox }
      fields[:has_marketers] = { renderer: :checkbox }
      fields[:has_retailer] = { renderer: :checkbox }
      fields[:active] = { renderer: :checkbox }
    end

    def common_fields
      {
        material_resource_type_id: { renderer: :select, options: @this_repo.for_select_material_resource_types, caption: 'Type' },
        sub_type_name: {}
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new
      config_form_object && return if @mode == :config

      @form_object = @this_repo.find_matres_sub_type(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(material_resource_type_id: nil,
                                    sub_type_name: nil)
    end

    def config_form_object
      @form_object = @this_repo.find_matres_config_for_sub_type(@options[:id])
    end
  end
end
