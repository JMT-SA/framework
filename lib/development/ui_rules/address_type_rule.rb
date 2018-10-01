# frozen_string_literal: true

module UiRules
  class AddressTypeRule < Base
    def generate_rules
      @repo = DevelopmentApp::AddressTypeRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'address_type'
    end

    def set_show_fields
      fields[:address_type] = { renderer: :label }
      fields[:active] = { renderer: :label, as_boolean: true }
    end

    def common_fields
      {
        address_type: { required: true },
        active: { renderer: :checkbox }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_address_type(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(address_type: nil,
                                    active: true)
    end
  end
end
