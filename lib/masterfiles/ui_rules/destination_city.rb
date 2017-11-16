# frozen_string_literal: true

module UiRules
  class DestinationCity < Base
    def generate_rules
      @repo = DestinationRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'destination_city'
    end

    def set_show_fields
      # country = @repo.find_country(@form_object.destination_country_id)
      # destination_country_id_label = country&.country_name
      # destination_region_id_label = @repo.find_region(country&.destination_region_id)&.destination_region_name
      # fields[:destination_region_id] = { renderer: :label, with_value: destination_region_id_label }
      # fields[:destination_country_id] = { renderer: :label, with_value: destination_country_id_label }
      fields[:region_name] = { renderer: :label }
      fields[:country_name] = { renderer: :label }
      fields[:city_name] = { renderer: :label }
    end

    def common_fields
      {
        destination_country_id: { renderer: :select, options: @repo.countries_for_select },
        city_name: {}
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
