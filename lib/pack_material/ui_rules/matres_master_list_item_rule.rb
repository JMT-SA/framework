# frozen_string_literal: true

module UiRules
  class MatresMasterListItemRule < Base
    def generate_rules
      @repo = PackMaterialApp::ConfigRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      form_name 'matres_master_list_item'
    end

    def common_fields
      {
        short_code: { required: true, force_uppercase: true },
        long_name: {},
        description: {},
        active: { renderer: :checkbox }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_matres_master_list_item(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(material_resource_master_list_id: nil,
                                    short_code: nil,
                                    long_name: nil,
                                    description: nil)
    end
  end
end
