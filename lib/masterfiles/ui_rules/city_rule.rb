# frozen_string_literal: true

module UiRules
  class CityRule < Base
    def generate_rules
      @repo = MasterfilesApp::DestinationRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'city'
    end

    def set_show_fields
      fields[:region_name] = { renderer: :label }
      fields[:country_name] = { renderer: :label }
      fields[:city_name] = { renderer: :label }
    end

    def common_fields
      {
        destination_country_id: { renderer: :select, options: @repo.for_select_destination_countries, caption: 'Country', required: true },
        city_name: { required: true }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_city(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(destination_country_id: nil,
                                    city_name: nil)
    end
  end
end
