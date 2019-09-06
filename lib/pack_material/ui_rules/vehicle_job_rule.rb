# frozen_string_literal: true

module UiRules
  class VehicleJobRule < Base
    def generate_rules
      @repo = PackMaterialApp::TripsheetsRepo.new
      @stock_repo = PackMaterialApp::MrStockRepo.new
      @location_repo = MasterfilesApp::LocationRepo.new
      @transaction_repo = PackMaterialApp::TransactionsRepo.new
      make_form_object
      apply_form_values
      set_rules unless @mode == :new

      common_values_for_fields common_fields

      set_show_fields if %i[show reopen].include? @mode

      form_name 'vehicle_job'
    end

    def set_rules # rubocop:disable Metrics/AbcSize
      # rules[:can_verify] = can_verify
      # rules[:can_review] = can_review
      # rules[:review_required] = review_required
      # rules[:can_add_invoice] = can_add_invoice
      # rules[:can_complete_invoice] = can_complete_invoice
      # rules[:invoice_completed] = @form_object.invoice_completed
      # rules[:is_verified] = @form_object.verified
      # rules[:over_supply_accepted] = @form_object.accepted_over_supply
      # rules[:del_sub_totals] = @repo.del_sub_totals(@options[:id])
    end

    def set_show_fields
      fields[:business_process_id] = { renderer: :label, with_value: @form_object.process, caption: 'Business Process' }
      fields[:vehicle_id] = { renderer: :label, with_value: @form_object.vehicle_code, caption: 'Vehicle' }
      fields[:departure_location_id] = { renderer: :label, with_value: @form_object.departure_location_long_code, caption: 'Departure Location' }
      fields[:tripsheet_number] = { renderer: :label }
      fields[:planned_location_id] = { renderer: :label, with_value: @form_object.planned_location_long_code, caption: 'Planned Location' }
      fields[:when_loaded] = { renderer: :label }
      fields[:when_offloaded] = { renderer: :label }
    end

    def common_fields
      {
        business_process_id: { renderer: :select, options: @transaction_repo.for_select_business_processes, selected: @repo.vehicle_jobs_business_process_id, caption: 'Business Process' },
        vehicle_id: { renderer: :select, options: @repo.for_select_vehicles, caption: 'Vehicle' },
        departure_location_id: { renderer: :select, options: @location_repo.for_select_locations, disabled_options: @location_repo.for_select_inactive_locations, caption: 'Departure Location' },
        tripsheet_number: { renderer: :label },
        planned_location_id: { renderer: :select, options: @location_repo.for_select_locations, disabled_options: @location_repo.for_select_inactive_locations, caption: 'Planned Location To' },
        when_loaded: { renderer: :label, subtype: :datetime },
        when_offloaded: { renderer: :label, subtype: :datetime }
      }
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
                                    when_loaded: nil,
                                    when_offloaded: nil)
    end

    # private

    # def add_approve_behaviours
    #   behaviours do |behaviour|
    #     behaviour.enable :reject_reason, when: :approve_action, changes_to: ['r']
    #   end
    # end
  end
end
