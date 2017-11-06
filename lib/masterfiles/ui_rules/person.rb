# frozen_string_literal: true

module UiRules
  class Person < Base
    def generate_rules
      @this_repo = PersonRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show
      set_role_fields if @mode == :roles

      form_name 'person'
    end

    def set_show_fields
      party_id_label = PartyRepo.new.find(@form_object.party_id)&.party_type
      # fields[:party_id] = { renderer: :label, with_value: party_id_label }
      fields[:surname] = { renderer: :label }
      fields[:first_name] = { renderer: :label }
      fields[:title] = { renderer: :label }
      fields[:vat_number] = { renderer: :label }
      fields[:role_id] = { renderer: :label }
      # fields[:active] = { renderer: :label }
    end

    def set_role_fields
    roles_repo = RoleRepo.new
      fields[:roles] = { renderer: :multi, options: roles_repo.for_select, selected: @form_object.roles.map(&:id) }
      fields[:name]  = { renderer: :label }
    end

    def common_fields
      {
        # party_id: { renderer: :select, options: PartyRepo.new.for_select },
        surname: {},
        first_name: {},
        title: {},
        vat_number: {},
        # active: { renderer: :checkbox },
        role_id: { renderer: :select, options: RoleRepo.new.for_select }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new
      make_roles_form_object && return if @mode == :roles

      @form_object = @this_repo.find(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(surname: nil,
                                    first_name: nil,
                                    title: nil,
                                    vat_number: nil,
                                    role_id: nil)
                                    # active: true)
    end

    def make_roles_form_object
      @form_object = @this_repo.find_with_roles(@options[:id])
    end
  end
end
