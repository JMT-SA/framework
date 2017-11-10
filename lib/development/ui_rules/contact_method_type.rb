# frozen_string_literal: true

module UiRules
  class ContactMethodType < Base
    def generate_rules
      @this_repo = ContactMethodTypeRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'contact_method_type'
    end

    def set_show_fields
      fields[:contact_method_type] = { renderer: :label }
    end

    def common_fields
      {
        contact_method_type: {}
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @this_repo.find(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(contact_method_type: nil)
    end
  end
end
