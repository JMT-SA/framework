# frozen_string_literal: true

module UiRules
  class OrganizationRule < Base
    def generate_rules
      @repo = PartyRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'organization'
    end

    def set_show_fields
      fields[:parent_organization] = { renderer: :label, caption: 'Parent' }
      fields[:short_description] = { renderer: :label }
      fields[:medium_description] = { renderer: :label }
      fields[:long_description] = { renderer: :label }
      fields[:vat_number] = { renderer: :label }
      fields[:role_names] = { renderer: :label, caption: 'Roles', with_value: @form_object.role_names.map(&:capitalize!).join(', ') }
      # fields[:variants] = { renderer: :label }
      # fields[:active] = { renderer: :label }
    end

    def common_fields
      # p @repo.roles_for_select
      # p @form_object
      {
        parent_id: { renderer: :select, options: @repo.organizations_for_select.reject{ |i| i.include?(@options[:id]) }, prompt: true },
        short_description: {},
        medium_description: {},
        long_description: {},
        vat_number: {},
        role_ids: { renderer: :multi, options: @repo.roles_for_select, selected: @form_object.role_ids }
        # variants: {},
        # active: { renderer: :checkbox }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_organization(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(short_description: nil,
                                    medium_description: nil,
                                    long_description: nil,
                                    vat_number: nil,
                                    role_ids: [])
                                    # variants: nil,
                                    # active: true)
    end
  end
end
