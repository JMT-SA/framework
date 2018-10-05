# frozen_string_literal: true

module UiRules
  class LocationAssignmentRule < Base
    def generate_rules
      @repo = MasterfilesApp::LocationRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'location_assignment'
    end

    def set_show_fields
      fields[:assignment_code] = { renderer: :label }
    end

    def common_fields
      {
        assignment_code: { required: true }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_location_assignment(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(assignment_code: nil)
    end
  end
end
