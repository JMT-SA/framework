# frozen_string_literal: true

module UiRules
  class MatresTypeRule < Base
    def generate_rules
      @this_repo = PackMaterialApp::ConfigRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'matres_type'
    end

    def set_show_fields
      fields[:domain_name] = { renderer: :label }
      fields[:type_name] = { renderer: :label }
      fields[:short_code] = { renderer: :label }
      fields[:description] = { renderer: :label }
      fields[:internal_seq] = { renderer: :label }
    end

    def common_fields
      {
        material_resource_domain_name: { renderer: :label, with_value: PackMaterialApp::DOMAIN_NAME, caption: 'Domain', readonly: true },
        material_resource_domain_id: { renderer: :hidden, with_value: @this_repo.domain_id },
        type_name: { required: true },
        short_code: { required: true, force_uppercase: true },
        description: {}
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @this_repo.find_matres_type(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(material_resource_domain_id: @this_repo.domain_id,
                                    type_name: nil)
    end
  end
end
