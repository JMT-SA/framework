# frozen_string_literal: true

module UiRules
  class VehicleJobUnitRule < Base
    def generate_rules
      @repo = PackMaterialApp::TripsheetsRepo.new
      @location_repo = MasterfilesApp::LocationRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields case @mode
                               when :new
                                 new_fields
                               when :edit
                                 edit_fields
                               when :show
                                 edit_fields
                               end

      set_show_fields if %i[show reopen].include? @mode

      form_name 'vehicle_job_unit'
    end

    def set_show_fields # rubocop:disable Metrics/AbcSize
      fields[:vehicle_job_id] = { renderer: :label, with_value: @form_object.tripsheet_number }
      fields[:quantity_to_move] = { renderer: :label }
      fields[:quantity_loaded] = { renderer: :label }
      fields[:quantity_offloaded] = { renderer: :label }
      fields[:when_loaded] = { renderer: :label }
      fields[:when_offloaded] = { renderer: :label }
      fields[:when_loading] = { renderer: :label }
      fields[:when_offloading] = { renderer: :label }
      fields[:mr_sku_id] = { renderer: :hidden }
      fields[:sku_number] = { renderer: :label, caption: 'SKU Number' }
      fields[:location_id] = { renderer: :label, with_value: @form_object.from_location_short_code, caption: 'From Location' }
    end

    def new_fields
      {
        sku_location_lookup: {
          renderer: :lookup,
          lookup_name: :vju_sku_locations,
          lookup_key: :standard,
          caption: 'Select SKU Location',
          param_values: { vehicle_job_id: vehicle_job_id }
        },
        vehicle_job_id: { renderer: :hidden },
        quantity_to_move: { renderer: :numeric, required: true },
        mr_sku_id: { renderer: :hidden },
        sku_number: { readonly: true, required: true },
        location_id: { renderer: :hidden },
        location_code: { readonly: true, required: true }
      }
    end

    def edit_fields
      {
        quantity_loaded: { renderer: :numeric },
        quantity_offloaded: { renderer: :numeric },
        when_loaded: { subtype: :datetime },
        when_offloaded: { subtype: :datetime },
        when_offloading: { subtype: :datetime },
        when_loading: { subtype: :datetime }
      }
    end

    def make_form_object
      if @mode == :new
        make_new_form_object
        return
      end

      @form_object = @repo.find_vehicle_job_unit(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(vehicle_job_id: @options[:parent_id],
                                    quantity_to_move: nil,
                                    when_loaded: nil,
                                    when_offloaded: nil,
                                    when_offloading: nil,
                                    quantity_loaded: nil,
                                    quantity_offloaded: nil,
                                    mr_sku_id: nil,
                                    sku_number: nil,
                                    location_id: nil,
                                    when_loading: nil)
    end

    def vehicle_job_id
      @options[:parent_id] || @form_object.vehicle_job_id
    end

    def sku_number_options
      @repo.vehicle_job_sku_numbers(vehicle_job_id)
    end

    def location_options
      @repo.vehicle_job_locations(vehicle_job_id)
    end
  end
end
