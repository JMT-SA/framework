# frozen_string_literal: true

module UiRules
  class MrPurchaseOrderRule < Base
    def generate_rules
      @repo = PackMaterialApp::ReplenishRepo.new
      @party_repo = MasterfilesApp::PartyRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields case @mode
                               when :edit
                                 edit_fields
                               when :new
                                 new_fields
                               when :preselect
                                 preselect_fields
                               end

      @rules[:sub_totals] = @repo.sub_totals(@options[:id]) if @mode == :edit
      form_name 'mr_purchase_order'
    end

    def common_fields
      {
        mr_delivery_term_id: {
          renderer: :select,
          options: @repo.for_select_mr_delivery_terms,
          caption: 'Delivery Term',
          required: true
        },
        mr_vat_type_id: {
          renderer: :select,
          options: @repo.for_select_mr_vat_types,
          caption: 'Vat Type',
          required: true
        },
        delivery_address_id: {
          renderer: :select,
          options: @party_repo.for_select_addresses_for_party(party_role_id: @form_object.supplier_party_role_id,
                                                              address_type: 'Delivery Address'),
          caption: 'Delivery Address',
          required: true
        },
        purchase_account_code: {},
        fin_object_code: {},
        valid_until: { subtype: :datetime, required: true }
      }
    end

    def edit_fields
      sup = supplier
      fields = {
        supplier_name: { renderer: :label, with_value: sup.party_name },
        supplier_erp_number: { renderer: :label, with_value: sup.erp_supplier_number },
        supplier_party_role_id: { renderer: :hidden },
        purchase_order_number: { renderer: :label }
      }
      fields.merge(common_fields)
    end

    def new_fields
      fields = {
        supplier_id: { renderer: :hidden },
        supplier_name: { renderer: :label },
        supplier_erp_number: { renderer: :label },
        supplier_party_role_id: { renderer: :hidden }
      }
      fields.merge(common_fields)
    end

    def preselect_fields
      {
        supplier_id: { renderer: :select, options: @repo.for_select_suppliers, caption: 'Please select the Supplier', required: true }
      }
    end

    def address_fields
      {
        delivery_address_id: {
          renderer: :select,
          options: @party_repo.for_select_addresses_for_party(party_role_id: @form_object.supplier_party_role_id,
                                                              address_type: 'Delivery Address'),
          caption: 'Delivery Address',
          required: true
        }
      }
    end

    def make_form_object
      make_preselect_form_object && return if @mode == :preselect
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_mr_purchase_order(@options[:id])
    end

    def make_preselect_form_object
      @form_object = OpenStruct.new(supplier_id: nil)
    end

    def make_new_form_object
      sup = supplier
      @form_object = OpenStruct.new(supplier_id: sup.id,
                                    supplier_name: sup.party_name,
                                    supplier_erp_number: sup.erp_supplier_number,
                                    mr_delivery_term_id: nil,
                                    supplier_party_role_id: sup.party_role_id,
                                    mr_vat_type_id: nil,
                                    delivery_address_id: nil,
                                    purchase_account_code: nil,
                                    fin_object_code: nil,
                                    valid_until: UtilityFunctions.weeks_since(Time.now, 1))
    end

    def supplier
      find_by_id = @options[:supplier_id] || @form_object.supplier_party_role_id
      MasterfilesApp::PartyRepo.new.find_supplier(find_by_id, by_party_role: @options[:supplier_id].nil?)
    end
  end
end
