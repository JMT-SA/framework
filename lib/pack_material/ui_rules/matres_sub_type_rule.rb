# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize

module UiRules
  class MatresSubTypeRule < Base
    def generate_rules
      @repo = PackMaterialApp::ConfigRepo.new
      make_form_object
      apply_form_values
      @rules[:sub_type_text] = @repo.matres_type_and_sub_type_description(@options[:id]).join(' / ') if @mode == :config

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'matres_sub_type'
    end

    def set_show_fields
      material_resource_type_id_label = @repo.find_matres_type(@form_object.material_resource_type_id)&.type_name
      fields[:material_resource_type_id] = { renderer: :label, with_value: material_resource_type_id_label, caption: 'Type' }
      fields[:sub_type_name] = { renderer: :label }
      fields[:short_code] = { renderer: :label }
      fields[:internal_seq] = { renderer: :label }
      fields[:product_code_separator] = { renderer: :label }
      fields[:has_suppliers] = { renderer: :label, as_boolean: true }
      fields[:has_marketers] = { renderer: :label, as_boolean: true }
      fields[:has_retailers] = { renderer: :label, as_boolean: true }
      fields[:active] = { renderer: :label, as_boolean: true }
    end

    def common_fields
      {
        material_resource_type_id: { renderer: :select, options: @repo.for_select_matres_types, caption: 'Type' },
        sub_type_name: { required: true },
        short_code: { required: true, force_uppercase: true },
        product_code_separator: { renderer: :label },
        has_suppliers: { renderer: :checkbox },
        has_marketers: { renderer: :checkbox },
        has_retailers: { renderer: :checkbox }
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
# rubocop:enable Metrics/AbcSize
