# frozen_string_literal: true

module UiRules
  class LocationRule < Base # rubocop:disable Metrics/ClassLength
    def generate_rules
      @repo = MasterfilesApp::LocationRepo.new
      @print_repo = LabelApp::PrinterRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show
      set_print_fields if @mode == :print_barcode

      add_behaviours if @options[:id]
      disable_can_be_moved

      form_name 'location'
    end

    private

    def set_show_fields # rubocop:disable Metrics/AbcSize
      primary_storage_type_id_label = @repo.find(:location_storage_types, MasterfilesApp::LocationStorageType, @form_object.primary_storage_type_id)&.storage_type_code
      location_type_id_label = @repo.find(:location_types, MasterfilesApp::LocationType, @form_object.location_type_id)&.location_type_code
      primary_assignment_id_label = @repo.find(:location_assignments, MasterfilesApp::LocationAssignment, @form_object.primary_assignment_id)&.assignment_code
      location_storage_definition_id_label = @repo.find(:location_storage_definitions, MasterfilesApp::LocationStorageDefinition, @form_object.location_storage_definition_id)&.storage_definition_code

      fields[:primary_storage_type_id] = { renderer: :label, with_value: primary_storage_type_id_label, caption: 'Primary Storage Type' }
      fields[:location_type_id] = { renderer: :label, with_value: location_type_id_label, caption: 'Location Type' }
      fields[:primary_assignment_id] = { renderer: :label, with_value: primary_assignment_id_label, caption: 'Primary Assignment' }
      fields[:location_storage_definition_id] = { renderer: :label, with_value: location_storage_definition_id_label, caption: 'Storage Definition' }
      fields[:location_long_code] = { renderer: :label, caption: 'Long Code' }
      fields[:location_description] = { renderer: :label, caption: 'Description' }
      fields[:location_short_code] = { renderer: :label, caption: 'Short Code' }
      fields[:print_code] = { renderer: :label }
      fields[:has_single_container] = { renderer: :label, as_boolean: true }
      fields[:virtual_location] = { renderer: :label, as_boolean: true }
      fields[:consumption_area] = { renderer: :label, as_boolean: true }
      fields[:storage_types] = { renderer: :list, items: storage_types }
      fields[:assignments] = { renderer: :list, items: location_assignments }
      fields[:can_be_moved] = { renderer: :label, as_boolean: true }
      fields[:can_store_stock] = { renderer: :label, as_boolean: true }
    end

    def set_print_fields
      fields[:location_long_code] = { renderer: :label, caption: 'Long Code' }
      fields[:location_description] = { renderer: :label, caption: 'Description' }
      fields[:printer] = { renderer: :select,
                           options: @print_repo.select_printers_for_application(AppConst::PRINT_APP_LOCATION),
                           required: true }
      fields[:no_of_prints] = { renderer: :integer, required: true }
    end

    def common_fields
      {
        primary_storage_type_id: { renderer: :select, options: storage_types, caption: 'Primary Storage Type', required: true },
        location_type_id: { renderer: :select, options: @repo.for_select_location_types, caption: 'Location Type', required: true },
        primary_assignment_id: { renderer: :select, options: location_assignments, caption: 'Primary Assignment', required: true },
        location_storage_definition_id: { renderer: :select, options: @repo.for_select_location_storage_definitions, caption: 'Storage Definition', prompt: true },
        location_long_code: { required: true, caption: 'Long Code' },
        location_description: { required: true, caption: 'Description' },
        location_short_code: { required: true, caption: 'Short Code' },
        print_code: { hint: '<h2>The print code is only used for displaying on labels.</h2><p>This can be used when the full location code is not required in order to understand a location because of context.</p><p>e.g. labels for racks within a building may not need to show the building code.</p>' },
        has_single_container: { renderer: :checkbox },
        virtual_location: { renderer: :checkbox },
        consumption_area: { renderer: :checkbox },
        can_be_moved: { renderer: :checkbox },
        can_store_stock: { renderer: :checkbox }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_location(@options[:id])
      @form_object = OpenStruct.new(@form_object.to_h.merge(printer: @print_repo.default_printer_for_application(AppConst::PRINT_APP_LOCATION), no_of_prints: 1)) if @mode == :print_barcode
    end

    def make_new_form_object
      parent = @options[:id].nil? ? nil : @repo.find_location(@options[:id])

      @form_object = OpenStruct.new(primary_storage_type_id: initial_storage_type(parent),
                                    location_type_id: @repo.for_select_location_types.first.last,
                                    primary_assignment_id: initial_assignment(parent),
                                    location_storage_definition_id: nil,
                                    location_long_code: initial_code(parent),
                                    location_description: nil,
                                    location_short_code: initial_short_code(parent),
                                    print_code: nil,
                                    has_single_container: nil,
                                    virtual_location: nil,
                                    consumption_area: nil,
                                    can_store_stock: false)
    end

    def storage_types
      if @mode == :edit || @mode == :show
        @repo.for_select_location_storage_types_for(@options[:id])
      else
        @repo.for_select_location_storage_types
      end
    end

    def location_assignments
      if @mode == :edit || @mode == :show
        @repo.for_select_location_assignments_for(@options[:id])
      else
        @repo.for_select_location_assignments
      end
    end

    def add_behaviours
      behaviours do |behaviour|
        behaviour.enable :can_be_moved, when: :location_type_id, changes_to: can_be_moved_location_type_ids
        behaviour.dropdown_change :location_type_id, notify: [{ url: "/masterfiles/locations/locations/#{@options[:id]}/add_child/location_type_changed" }]
        behaviour.dropdown_change :primary_storage_type_id, notify: [{ url: "/masterfiles/locations/locations/#{@options[:id]}/primary_storage_type_changed" }]
      end
    end

    def initial_code(parent)
      return nil if parent.nil?

      location_type_id = @repo.for_select_location_types.first.last
      res = @repo.location_long_code_suggestion(parent.id, location_type_id)
      res.success ? res.instance : nil
    end

    def initial_short_code(parent)
      storage_type_id = parent.primary_storage_type_id
      res = @repo.suggested_short_code(storage_type_id)
      res.instance
    end

    def initial_storage_type(parent)
      return nil if parent.nil?

      parent.primary_storage_type_id
    end

    def initial_assignment(parent)
      return nil if parent.nil?

      parent.primary_assignment_id
    end

    def disable_can_be_moved
      fields[:can_be_moved][:disabled] = true unless location_type_can_be_moved?
    end

    def location_type_can_be_moved?
      loc_type_id = @form_object.location_type_id
      can_be_moved_location_type_ids.include?(loc_type_id)
    end

    def can_be_moved_location_type_ids
      @repo.can_be_moved_location_type_ids
    end
  end
end
