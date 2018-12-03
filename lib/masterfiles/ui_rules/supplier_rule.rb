# frozen_string_literal: true

module UiRules
  class SupplierRule < Base
    def generate_rules
      @repo = MasterfilesApp::PartyRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields @mode == :preselect ? preselect_fields : common_fields

      set_show_fields if @mode == :show

      form_name 'supplier'
    end

    def set_show_fields
      fields[:party_name] = { renderer: :label }
      fields[:party_role_id] = { renderer: :hidden }
      fields[:supplier_types] = { renderer: :list, items: @form_object.supplier_types, caption: 'Supplier Types' }
      fields[:erp_supplier_number] = { renderer: :label }
    end

    def common_fields
      {
        party_name: { renderer: :label, with_value: @repo.find_party(party_id)&.party_name },
        party_id: { renderer: :hidden, with_value: party_id },
        supplier_type_ids: { renderer: :multi, options: @repo.for_select_supplier_types, selected: @form_object.supplier_type_ids, caption: 'Supplier Types', required: true },
        erp_supplier_number: {}
      }
    end

    def preselect_fields
      {
        party_id: { renderer: :select, options: @repo.for_select_supplier_parties, caption: 'Please select existing party', required: true }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new
      make_preselect_form_object && return if @mode == :preselect

      @form_object = @repo.find_supplier(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(party_id: @options[:party_id],
                                    supplier_type_id: nil,
                                    erp_supplier_number: nil)
    end

    def party_id
      @options[:party_id] || @repo.find_hash(:party_roles, @form_object.party_role_id)[:party_id]
    end

    def make_preselect_form_object
      @form_object = OpenStruct.new(party_id: nil)
    end
  end
end
