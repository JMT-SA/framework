# frozen_string_literal: true

module UiRules
  class LocationStorageTypeRule < Base
    def generate_rules
      @repo = MasterfilesApp::LocationRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'location_storage_type'
    end

    def set_show_fields
      fields[:storage_type_code] = { renderer: :label }
      fields[:location_short_code_prefix] = { renderer: :label }
    end

    def common_fields
      {
        storage_type_code: { required: true },
        location_short_code_prefix: {}
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_location_storage_type(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(storage_type_code: nil, location_short_code_prefix: nil)
    end
  end
end
