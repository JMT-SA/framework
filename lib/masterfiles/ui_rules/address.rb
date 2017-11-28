# frozen_string_literal: true

module UiRules
  class Address < Base
    def generate_rules
      @repo = PartyRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'address'
    end

    def set_show_fields
      fields[:address_type] = { renderer: :label }
      fields[:address_line_1] = { renderer: :label }
      fields[:address_line_2] = { renderer: :label }
      fields[:address_line_3] = { renderer: :label }
      fields[:city] = { renderer: :label }
      fields[:postal_code] = { renderer: :label }
      fields[:country] = { renderer: :label }
      fields[:active] = { renderer: :label }
    end

    def common_fields
      {
        address_type_id: { renderer: :select, options: AddressTypeRepo.new.for_select },
        address_line_1: {},
        address_line_2: {},
        address_line_3: {},
        city: {},
        postal_code: {},
        country: {},
        active: { renderer: :checkbox }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_address(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(address_type_id: nil,
                                    address_line_1: nil,
                                    address_line_2: nil,
                                    address_line_3: nil,
                                    city: nil,
                                    postal_code: nil,
                                    country: nil,
                                    active: true)
    end
  end
end
