# frozen_string_literal: true

module UiRules
  class PersonRule < Base
    def generate_rules
      @repo = PartyRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'person'
    end

    def set_show_fields
      fields[:surname] = { renderer: :label }
      fields[:first_name] = { renderer: :label }
      fields[:title] = { renderer: :label }
      fields[:vat_number] = { renderer: :label }
      fields[:active] = { renderer: :label }
      fields[:role_names] = { renderer: :label, caption: "Roles", with_value: @form_object.role_names.map(&:capitalize!).join(', ') }
    end

    def common_fields
      {
        surname: {},
        first_name: {},
        title: {},
        vat_number: {},
        active: { renderer: :checkbox },
        role_ids: { renderer: :multi, options: @repo.roles_for_select, selected: @form_object.role_ids }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_person(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(surname: nil,
                                    first_name: nil,
                                    title: nil,
                                    vat_number: nil,
                                    active: true,
                                    role_ids: [])
    end

  end
end
