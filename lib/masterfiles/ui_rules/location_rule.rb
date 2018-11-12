# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize

module UiRules
  class LocationRule < Base
    def generate_rules
      @repo = MasterfilesApp::LocationRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show
      set_print_fields if @mode == :print_barcode

      add_behaviours if @options[:id]

      form_name 'location'
    end

    private

    def set_show_fields
      primary_storage_type_id_label = @repo.find(:location_storage_types, MasterfilesApp::LocationStorageType, @form_object.primary_storage_type_id)&.storage_type_code
      location_type_id_label = @repo.find(:location_types, MasterfilesApp::LocationType, @form_object.location_type_id)&.location_type_code
      primary_assignment_id_label = @repo.find(:location_assignments, MasterfilesApp::LocationAssignment, @form_object.primary_assignment_id)&.assignment_code

      fields[:primary_storage_type_id] = { renderer: :label, with_value: primary_storage_type_id_label, caption: 'Primary Storage Type' }
      fields[:location_type_id] = { renderer: :label, with_value: location_type_id_label, caption: 'Location Type' }
      fields[:primary_assignment_id] = { renderer: :label, with_value: primary_assignment_id_label, caption: 'Primary Assignment' }
      fields[:location_code] = { renderer: :label, caption: 'Code' }
      fields[:location_description] = { renderer: :label, caption: 'Description' }
      fields[:has_single_container] = { renderer: :label, as_boolean: true }
      fields[:virtual_location] = { renderer: :label, as_boolean: true }
      fields[:consumption_area] = { renderer: :label, as_boolean: true }
      fields[:storage_types] = { renderer: :list, items: storage_types }
      fields[:assignments] = { renderer: :list, items: location_assignments }
    end

    def set_print_fields
      printers = [['Label Designer', 'PRN-01']] # @repo.for_select_location_types # FIXME: hard-coded list...
      fields[:location_code] = { renderer: :label, caption: 'Code' }
      fields[:location_description] = { renderer: :label, caption: 'Description' }
      fields[:printer] = { renderer: :select, options: printers, required: true }
      fields[:no_of_prints] = { renderer: :integer, required: true }
    end

    def common_fields
      {
        primary_storage_type_id: { renderer: :select, options: storage_types, caption: 'Primary Storage Type', required: true },
        location_type_id: { renderer: :select, options: @repo.for_select_location_types, caption: 'Location Type', required: true },
        primary_assignment_id: { renderer: :select, options: location_assignments, caption: 'Primary Assignment', required: true },
        location_code: { required: true, caption: 'Code' },
        location_description: { required: true, caption: 'Description' },
        has_single_container: { renderer: :checkbox },
        virtual_location: { renderer: :checkbox },
        consumption_area: { renderer: :checkbox }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_location(@options[:id])
      @form_object = OpenStruct.new(@form_object.to_h.merge(printer: nil, no_of_prints: 1)) if @mode == :print_barcode
    end

    def make_new_form_object
      parent = @options[:id].nil? ? nil : @repo.find_location(@options[:id])

      @form_object = OpenStruct.new(primary_storage_type_id: initial_storage_type(parent),
                                    location_type_id: nil,
                                    primary_assignment_id: initial_assignment(parent),
                                    location_code: initial_code(parent),
                                    location_description: nil,
                                    has_single_container: nil,
                                    virtual_location: nil,
                                    consumption_area: nil)
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
        behaviour.dropdown_change :location_type_id, notify: [{ url: "/masterfiles/locations/locations/#{@options[:id]}/add_child/location_type_changed" }]
      end
    end

    def initial_code(parent)
      return nil if parent.nil?

      location_type_id = @repo.for_select_location_types.first.last
      res = @repo.location_code_suggestion(parent.id, location_type_id)
      res.success ? res.instance : nil
    end

    def initial_storage_type(parent)
      return nil if parent.nil?

      parent.primary_storage_type_id
    end

    def initial_assignment(parent)
      return nil if parent.nil?

      parent.primary_assignment_id
    end
  end
end
# rubocop:enable Metrics/AbcSize
