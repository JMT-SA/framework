# frozen_string_literal: true

module UiRules
  class LocationTypeRule < Base
    def generate_rules
      @repo = PackMaterialApp::LocationRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'location_type'
    end

    def set_show_fields
      fields[:location_type_code] = { renderer: :label }
    end

    def common_fields
      {
        location_type_code: { required: true }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_location_type(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(location_type_code: nil)
    end
  end
end
