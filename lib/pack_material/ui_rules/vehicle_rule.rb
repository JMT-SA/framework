# frozen_string_literal: true

module UiRules
  class VehicleRule < Base
    def generate_rules
      @repo = PackMaterialApp::TripsheetsRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if %i[show reopen].include? @mode

      form_name 'vehicle'
    end

    def set_show_fields
      vehicle_type_id_label = @repo.find(:vehicle_types, PackMaterialApp::VehicleType, @form_object.vehicle_type_id)&.type_code
      fields[:vehicle_type_id] = { renderer: :label, with_value: vehicle_type_id_label, caption: 'Vehicle Type' }
      fields[:vehicle_code] = { renderer: :label }
    end

    def common_fields
      {
        vehicle_type_id: { renderer: :select, options: PackMaterialApp::TripsheetsRepo.new.for_select_vehicle_types, caption: 'Vehicle Type', required: true },
        vehicle_code: {}
      }
    end

    def make_form_object
      if @mode == :new
        make_new_form_object
        return
      end

      @form_object = @repo.find_vehicle(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(vehicle_type_id: nil,
                                    vehicle_code: nil)
    end
  end
end
