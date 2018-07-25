# frozen_string_literal: true

module UiRules
  class MatresTypeRule < Base
    def generate_rules
      @this_repo = PackMaterialApp::ConfigRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields @mode == :add_unit ? unit_fields : common_fields

      set_show_fields if @mode == :show
      add_behaviour
      disable_new_unit_of_measure if @mode == :add_unit
      form_name 'matres_type'
    end

    def set_show_fields
      fields[:domain_name] = { renderer: :label }
      fields[:type_name] = { renderer: :label }
      fields[:short_code] = { renderer: :label }
      fields[:description] = { renderer: :label }
      fields[:internal_seq] = { renderer: :label }
      fields[:measurement_units] = { renderer: :list, items: @this_repo.matres_type_measurement_units(@options[:id]), caption: 'Measurement Units' }
    end

    def unit_fields
      {
        unit_of_measure: { renderer: :select, options: measurement_units_list, caption: 'Unit of Measurement', selected: 'other' },
        other: { force_lowercase: true, caption: 'Other' }
      }
    end

    def common_fields
      {
        material_resource_domain_id: { renderer: :select, options: @this_repo.for_select_domains, caption: 'Domain' },
        type_name: { required: true },
        short_code: { required: true },
        description: {},
        measurement_units: { renderer: :multi, options: @this_repo.for_select_units, selected: @this_repo.matres_type_measurement_unit_ids(@options[:id]), caption: 'Measurement Units' }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new
      make_unit_form_object && return if @mode == :add_unit

      @form_object = @this_repo.find_matres_type(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(material_resource_domain_id: nil,
                                    type_name: nil)
    end

    def make_unit_form_object
      @form_object = OpenStruct.new(unit_of_measure: nil,
                                    other: nil)
    end

    private

    def add_behaviour
      behaviours do |behaviour|
        behaviour.enable :other, when: :unit_of_measure, changes_to: ['other']
      end
    end

    def disable_new_unit_of_measure
      fields[:other][:disabled] = true unless form_object.unit_of_measure == 'other' || form_object.unit_of_measure.nil?
    end

    def measurement_units_list
      @this_repo.measurement_units + ['other']
    end
  end
end
