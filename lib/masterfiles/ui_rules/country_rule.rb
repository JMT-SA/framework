# frozen_string_literal: true

module UiRules
  class CountryRule < Base
    def generate_rules
      @repo = MasterfilesApp::DestinationRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'country'
    end

    def set_show_fields
      destination_region_id_label = @repo.find(:destination_regions, MasterfilesApp::Region, @form_object.destination_region_id)&.destination_region_name
      fields[:destination_region_id] = { renderer: :label, with_value: destination_region_id_label, caption: 'Destination Region' }
      fields[:region_name] = { renderer: :label }
      fields[:country_name] = { renderer: :label }
      fields[:active] = { renderer: :label, as_boolean: true }
      fields[:iso_country_code] = { renderer: :label }
    end

    def common_fields
      show_region = !@options[:region_id].nil?
      {
        destination_region_id: { renderer: :select, options: @repo.for_select_destination_regions, caption: 'Region', required: true, invisible: show_region },
        country_name: { required: true },
        iso_country_code: { renderer: :select, options: AppConst::ISO_COUNTRY_CODES, required: true }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_country(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(destination_region_id: nil,
                                    country_name: nil,
                                    iso_country_code: nil)
    end
  end
end
