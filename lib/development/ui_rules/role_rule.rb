# frozen_string_literal: true

module UiRules
  class RoleRule < Base
    def generate_rules
      @repo = DevelopmentApp::RoleRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'role'
    end

    def set_show_fields
      fields[:name] = { renderer: :label }
      fields[:active] = { renderer: :label, as_boolean: true }
    end

    def common_fields
      {
        name: { force_uppercase: true, required: true },
        active: { renderer: :checkbox }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_role(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(name: nil,
                                    active: true)
    end
  end
end
