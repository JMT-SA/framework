# frozen_string_literal: true

require 'faker'

module PackMaterialApp
  module PmProductFactory
    # uses ConfigFactory

    def create_pack_material_product_variant
      product = create_product
      default = {
        pack_material_product_id: product[:id],
        reference_size: 'size',
        reference_dimension: 'dim',
        reference_quantity: 'qty'
      }
      id = DB[:pack_material_product_variants].insert(default)
      DB[:pack_material_product_variants].where(id: id).first
    end

    def create_material_resource_product_variant(opts = {})
      variant = create_pack_material_product_variant
      sub_type_id = DB[:pack_material_products].where(id: variant[:pack_material_product_id]).first[:material_resource_sub_type_id]
      default = {
        sub_type_id: sub_type_id,
        product_variant_id: variant[:id],
        product_variant_table_name: 'pack_material_product_variants',
        product_variant_number: variant[:product_variant_number],
        product_variant_code: variant[:product_variant_code]
      }
      {
        id: DB[:material_resource_product_variants].insert(default.merge(opts)),
        product_variant_id: variant[:id]
      }
    end

    def create_matres_product_variant_party_role(type = MasterfilesApp::SUPPLIER_ROLE, opts = {})
      variant = create_material_resource_product_variant
      supplier = create_supplier
      customer = create_customer
      supplier_type = type == MasterfilesApp::SUPPLIER_ROLE
      supplier_id = supplier_type ? supplier[:id] : nil
      customer_id = supplier_type ? nil : customer[:id]
      default = {
        supplier_id: supplier_id,
        customer_id: customer_id,
        material_resource_product_variant_id: variant[:id],
        supplier_lead_time: 12
      }
      role_link_id = DB[:material_resource_product_variant_party_roles].insert(default.merge(opts))
      {
        id: role_link_id,
        supplier_id: supplier_id,
        customer_id: customer_id
      }
    end
  end
end
