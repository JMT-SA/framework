# frozen_string_literal: true

module UiRules
  class VehicleJobRule < Base
    def generate_rules
      @repo = PackMaterialApp::TripsheetsRepo.new
      @stock_repo = PackMaterialApp::MrStockRepo.new
      @location_repo = MasterfilesApp::LocationRepo.new
      @transaction_repo = PackMaterialApp::TransactionsRepo.new
      @tripsheets_repo = PackMaterialApp::TripsheetsRepo.new
      make_form_object
      apply_form_values
      set_rules unless @mode == :new

      common_values_for_fields can_edit? ? edit_fields : update_fields

      set_show_fields if %i[show reopen].include? @mode

      form_name 'vehicle_job'
    end

    def set_rules
      rules[:can_confirm_arrival] = can_confirm_arrival?
      rules[:arrival_confirmed] = arrival_confirmed?
      rules[:can_load] = can_mark_as_loaded?
      rules[:loaded] = loaded?
      rules[:cannot_edit] = !can_edit?
      rules[:completed] = completed?
    end

    def set_show_fields # rubocop:disable Metrics/AbcSize
      # TODO: Update show view
      fields[:business_process_id] = { renderer: :label, with_value: @form_object.process, caption: 'Business Process' }
      fields[:vehicle_id] = { renderer: :label, with_value: @form_object.vehicle_code, caption: 'Vehicle' }
      fields[:departure_location_id] = { renderer: :label, with_value: @form_object.departure_location_long_code, caption: 'Departure Location' }
      fields[:tripsheet_number] = { renderer: :label }
      fields[:planned_location_id] = { renderer: :label, with_value: @form_object.planned_location_long_code, caption: 'Planned Location' }
      fields[:virtual_location_id] = { renderer: :label, with_value: @form_object.virtual_location_long_code, caption: 'Virtual Location' }
      fields[:when_loaded] = { renderer: :label }
      fields[:when_offloaded] = { renderer: :label }
      fields[:arrival_confirmed] = { renderer: :label, as_boolean: true }
      fields[:loaded] = { renderer: :label, as_boolean: true }
      fields[:offloaded] = { renderer: :label, as_boolean: true }
    end

    def edit_fields
      {
        business_process_id: { renderer: :select, options: @transaction_repo.for_select_business_processes, selected: @repo.vehicle_jobs_business_process_id, caption: 'Business Process', required: true },
        vehicle_id: { renderer: :select, options: @repo.for_select_vehicles, caption: 'Vehicle', required: true },
        departure_location_id: { renderer: :select, options: @tripsheets_repo.departure_locations, caption: 'Departure Location', required: true },
        tripsheet_number: { renderer: :label },
        planned_location_id: { renderer: :select, options: receiving_bays, caption: 'Planned Location To', prompt: 'Leave blank if same Building' },
        virtual_location_id: { renderer: :select, options: @location_repo.for_select_locations(where: { virtual_location: true }), caption: 'Virtual Location', required: true },
        when_loaded: { renderer: :label, subtype: :datetime },
        when_offloaded: { renderer: :label, subtype: :datetime },
        arrival_confirmed: { renderer: :label, as_boolean: true },
        loaded: { renderer: :label, as_boolean: true },
        offloaded: { renderer: :label, as_boolean: true }
      }
    end

    def update_fields
      {
        business_process_id: { renderer: :label },
        vehicle_id: { renderer: :label },
        departure_location_id: { renderer: :label },
        tripsheet_number: { renderer: :label },
        planned_location_id: { renderer: :select, options: receiving_bays, caption: 'Planned Location To', prompt: 'Leave blank if same Building' },
        virtual_location_id: { renderer: :label },
        when_loaded: { renderer: :label, subtype: :datetime },
        when_offloaded: { renderer: :label, subtype: :datetime },
        arrival_confirmed: { renderer: :label, as_boolean: true },
        loaded: { renderer: :label, as_boolean: true },
        offloaded: { renderer: :label, as_boolean: true }
      }
    end

    def receiving_bays
      @location_repo.for_select_receiving_bays
    end

    def make_form_object
      if @mode == :new
        make_new_form_object
        return
      end

      @form_object = @repo.find_vehicle_job(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(business_process_id: nil,
                                    vehicle_id: nil,
                                    departure_location_id: nil,
                                    tripsheet_number: nil,
                                    planned_location_id: nil,
                                    virtual_location_id: nil,
                                    when_loaded: nil,
                                    loaded: nil,
                                    offloaded: nil,
                                    arrival_confirmed: nil,
                                    when_offloaded: nil)
    end

    def can_confirm_arrival?
      interactor.check_permission(:can_confirm_arrival, @options[:id])
    end

    def can_mark_as_loaded?
      interactor.check_permission(:can_mark_as_loaded, @options[:id])
    end

    def arrival_confirmed?
      @form_object.arrival_confirmed
    end

    def loaded?
      @form_object.loaded
    end

    def completed?
      @form_object.offloaded
    end

    def interactor
      @interactor ||= @options[:interactor]
    end

    def can_edit?
      @can_edit ||= interactor.check_permission(:edit, @options[:id])
    end
  end
end
