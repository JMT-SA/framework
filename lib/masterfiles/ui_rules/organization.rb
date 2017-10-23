# frozen_string_literal: true

module UiRules
  class Organization < Base
    def generate_rules
      @this_repo = OrganizationRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'organization'
    end

    def set_show_fields # rubocop:disable Metrics/AbcSize
      party_id_label = PartyRepo.new.find(@form_object.party_id)&.party_type
      parent_id_label = OrganizationRepo.new.find(@form_object.parent_id)&.short_description
      # fields[:party_id] = { renderer: :label, with_value: party_id_label }
      # fields[:parent_id] = { renderer: :label, with_value: parent_id_label }
      fields[:short_description] = { renderer: :label }
      fields[:medium_description] = { renderer: :label }
      fields[:long_description] = { renderer: :label }
      fields[:vat_number] = { renderer: :label }
      fields[:role_id] = { renderer: :label }
      # fields[:variants] = { renderer: :label }
      # fields[:active] = { renderer: :label }
    end

    def common_fields
      {
        # party_id: { renderer: :select, options: PartyRepo.new.for_select },
        # parent_id: { renderer: :select, options: OrganizationRepo.new.for_select },
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
  end
end
