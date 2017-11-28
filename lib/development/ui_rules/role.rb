# frozen_string_literal: true

module UiRules
  class RoleRule < Base
    def generate_rules
      @this_repo = RoleRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'role'
    end

    def set_show_fields
      fields[:name] = { renderer: :label }
      fields[:active] = { renderer: :label }
    end

    def common_fields
      {
        name: { force_uppercase: true },
        active: { renderer: :checkbox }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @this_repo.find(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(name: nil,
                                    active: true)
    end
  end
end
