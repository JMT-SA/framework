# frozen_string_literal: true

module UiRules
  class DestinationRegionRule < Base
    def generate_rules
      @repo = DestinationRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'destination_region'
    end

    def set_show_fields
      fields[:destination_region_name] = { renderer: :label }
    end

    def common_fields
      {
        destination_region_name: {}
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_region(@options[:id])
      #TODO: move -> DestinationInteractor.find_region(id) ?
    end

    def make_new_form_object
      @form_object = OpenStruct.new(destination_region_name: nil)
    end
  end
end
