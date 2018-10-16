# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize

module UiRules
  class MatresProductVariantPartyRoleRule < Base
    def generate_rules
      @repo = PackMaterialApp::ConfigRepo.new
      @party_repo = MasterfilesApp::PartyRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields form_fields

      set_show_fields if @mode == :show

      form_name 'matres_product_variant_party_role'
    end

    def set_show_fields
      supplier = @form_object.supplier_id
      fields[:product_variant_code] = { renderer: :label, with_value: product_variant.product_variant_code, caption: 'Product Code' }
      fields[:product_variant_number] = { renderer: :label, with_value: product_variant.product_variant_number, caption: 'Product Number' }
      fields[:party_name] = { renderer: :label, with_value: supplier ? supplier_name : customer_name, caption: 'Name', readonly: true }
      fields[:party_stock_code] = { renderer: :label, caption: 'Stock Code' }
      fields[:supplier_lead_time] = { renderer: :label, caption: 'Lead Time (days)' } if supplier
      fields[:is_preferred_supplier] = { renderer: :label, as_boolean: true } if supplier
    end

    def supplier_name
      @party_repo.find_supplier(@form_object.supplier_id)&.party_name
    end

    def customer_name
      @party_repo.find_customer(@form_object.customer_id)&.party_name
    end

    def form_fields
      supplier = @options[:type] == MasterfilesApp::SUPPLIER_ROLE.downcase
      supplier = @repo.find_party_role(@options[:id])&.supplier? if @mode == :edit
      {
        material_resource_product_variant_id: { renderer: :hidden, required: true },
        product_variant_code: { renderer: :label, with_value: product_variant.product_variant_code, readonly: true, caption: 'Product Code' },
        product_variant_number: { renderer: :label, with_value: product_variant.product_variant_number, readonly: true, caption: 'Product Number' },
        supplier_id: supplier ? { renderer: :select, options: @party_repo.for_select_suppliers, caption: 'Supplier' } : { renderer: :hidden },
        customer_id: supplier ? { renderer: :hidden } : { renderer: :select, options: @party_repo.for_select_customers, caption: 'Customer' },
        party_stock_code: { caption: "#{supplier ? 'Supplier' : 'Customer'} Stock Code", required: true },
        supplier_lead_time: (supplier ? { caption: 'Lead Time (days)' } : { renderer: :hidden }),
        is_preferred_supplier: (supplier ? { renderer: :checkbox } : { renderer: :hidden })
      }
    end

    def product_variant
      variant_id = @options[:parent_id] || @form_object.material_resource_product_variant_id
      @repo.find_matres_product_variant(variant_id)
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_party_role(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(material_resource_product_variant_id: nil,
                                    supplier_id: nil,
                                    customer_id: nil,
                                    party_stock_code: nil,
                                    supplier_lead_time: nil,
                                    is_preferred_supplier: true)
    end
  end
end
# rubocop:enable Metrics/AbcSize
