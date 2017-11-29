# frozen_string_literal: true

module UiRules
  class ContactMethodRule < Base
    def generate_rules
      @repo = PartyRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'contact_method'
    end

    def set_show_fields
      fields[:contact_method_type_id] = { renderer: :label,
                                          with_value: @repo.find_contact_method(@form_object.contact_method_type_id)&.contact_method_type }
      fields[:contact_method_type] = { renderer: :label }
      fields[:contact_method_code] = { renderer: :label }
      fields[:active] = { renderer: :label }
    end

    def common_fields
      {
        contact_method_type_id: { renderer: :select, options: @repo.for_select_contact_method_types },
        contact_method_code: {},
        active: { renderer: :checkbox }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_contact_method(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(contact_method_type_id: nil,
                                    contact_method_code: nil,
                                    active: true)
    end
  end
end
