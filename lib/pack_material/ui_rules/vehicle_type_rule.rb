# frozen_string_literal: true

module UiRules
  class VehicleTypeRule < Base
    def generate_rules
      @repo = PackMaterialApp::TripsheetsRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if %i[show reopen].include? @mode

      form_name 'vehicle_type'
    end

    def set_show_fields
      fields[:type_code] = { renderer: :label }
    end

    def common_fields
      {
        type_code: { required: true }
      }
    end

    def make_form_object
      if @mode == :new
        make_new_form_object
        return
      end

      @form_object = @repo.find_vehicle_type(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(type_code: nil)
    end
  end
end
