# frozen_string_literal: true

module UiRules
  class Organization < Base
    def generate_rules
      @this_repo = OrganizationRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show
      set_role_fields if @mode == :roles

      form_name 'organization'
    end

    def set_show_fields
      parent_id_label = OrganizationRepo.new.find(@form_object.parent_id)&.short_description
      fields[:parent_id] = { renderer: :label, with_value: parent_id_label }
      fields[:short_description] = { renderer: :label }
      fields[:medium_description] = { renderer: :label }
      fields[:long_description] = { renderer: :label }
      fields[:vat_number] = { renderer: :label }
      # fields[:variants] = { renderer: :label }
      # fields[:active] = { renderer: :label }
      #TODO Add roles to view
      # Add addresses to view?
      # fields[:roles] = { renderer: :label }
    end

    def set_role_fields
      roles_repo = RoleRepo.new
      fields[:roles] = { renderer: :multi, options: roles_repo.for_select, selected: @form_object.roles.map(&:id) }
      fields[:name]  = { renderer: :label }
    end

    def common_fields
      {
        parent_id: { renderer: :select, options: OrganizationRepo.new.for_select.reject{|i| i.include?(@options[:id])} },
        short_description: {},
        medium_description: {},
        long_description: {},
        vat_number: {},
        role_id: { renderer: :select, options: RoleRepo.new.for_select },
        # variants: {},
        # active: { renderer: :checkbox }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new
      make_roles_form_object && return if @mode == :roles

      @form_object = @this_repo.find(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(short_description: nil,
                                    medium_description: nil,
                                    long_description: nil,
                                    vat_number: nil,
                                    role_id: nil)
                                    # variants: nil,
                                    # active: true)
    end

    def make_roles_form_object
      @form_object = @this_repo.find_with_roles(@options[:id])
    end
  end
end
