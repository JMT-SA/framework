# frozen_string_literal: true

module UiRules
  class LocationStorageDefinitionRule < Base
    def generate_rules
      @repo = MasterfilesApp::LocationRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'location_storage_definition'
    end

    def set_show_fields
      fields[:storage_definition_code] = { renderer: :label, caption: 'Code' }
      fields[:storage_definition_format] = { renderer: :label, caption: 'Format' }
      fields[:storage_definition_description] = { renderer: :label, caption: 'Description' }
      fields[:active] = { renderer: :label, as_boolean: true }
    end

    def common_fields
      {
        storage_definition_code: { required: true, caption: 'Code' },
        storage_definition_format: { required: true, caption: 'Format' },
        storage_definition_description: { required: true, caption: 'Description' }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_location_storage_definition(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(storage_definition_code: nil,
                                    storage_definition_format: nil,
                                    storage_definition_description: nil)
    end
  end
end
