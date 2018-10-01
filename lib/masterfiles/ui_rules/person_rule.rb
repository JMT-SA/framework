# frozen_string_literal: true

module UiRules
  class PersonRule < Base
    def generate_rules
      @repo = MasterfilesApp::PartyRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'person'
    end

    def set_show_fields
      fields[:party_name] = { renderer: :label, caption: 'Full Name' }
      fields[:surname] = { renderer: :label }
      fields[:first_name] = { renderer: :label }
      fields[:title] = { renderer: :label }
      fields[:vat_number] = { renderer: :label }
      fields[:active] = { renderer: :label, as_boolean: true }
      fields[:role_names] = { renderer: :list, caption: 'Roles', items: @form_object.role_names.map(&:capitalize!) }
    end

    def common_fields
      {
        surname: { required: true },
        first_name: { required: true },
        title: { required: true },
        vat_number: {},
        active: { renderer: :checkbox },
        role_ids: { renderer: :multi, options: @repo.for_select_roles, selected: @form_object.role_ids, required: true  }
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
