# frozen_string_literal: true

module Settings
  module PackMaterialProducts
    module PackMaterialProduct
      class New
        def self.call(form_values: nil, form_errors: nil, remote: true) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:pack_material_product, :new, form_values: form_values)
          rules = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action '/settings/pack_material_products/pack_material_products'
              form.remote! if remote # Make this a remote form that will be submitted via a javascript fetch.

              form.add_field :material_resource_sub_type_id
              p "did I get in here"
              form.submit_captions "Next"
            end
          end

          layout
        end
      end
    end
  end
end

#
# Integer :product_number, null: false
# String :description
#
# foreign_key :commodity_id, :commodities, null: false, key: [:id]
# # foreign_key :variety_id, :varieties, null: false, key: [:id]
# # String :commodity_id #Lookup
# String :variety_id #Lookup
# # String :variant
# String :style
# String :assembly_type
# String :market_major
# String :ctn_size_basic #Lookup
# String :ctn_size_old_pack #Lookup
# String :pls_pack_code #Lookup
# Numeric :fruit_mass_nett_kg #NOTE: should we add a unit in here for LB or KG
# String :holes
# String :perforation
# String :image, text: true
# Numeric :length_mm
# Numeric :width_mm
# Numeric :height_mm
# Numeric :diameter_mm
# Numeric :thick_mm
# Numeric :thick_mic
# String :colour
# String :grade
# String :mass
# String :material_type
# String :treatment
# String :specification_notes, text: true
# String :artwork_commodity
# String :artwork_marketing_variety_group
# String :artwork_variety
# String :artwork_nett_mass
# String :artwork_brand
# String :artwork_class
# Numeric :artwork_plu_number
# String :artwork_other
# String :artwork_image, text: true
# String :marketer #Lookup
# String :retailer #Lookup
# String :supplier #Lookup #AlwaysActive
# String :supplier_stock_code #AlwaysActive
# String :product_alternative #Validate if the product code given here is a valid entry
# String :product_joint_use #Validate if the product code given here is a valid entry
# String :ownership
# TrueClass :consignment_stock, default: false
# Date :start_date #AlwaysActive
# Date :end_date #AlwaysActive
# TrueClass :active, default: true #AlwaysActive
# String :remarks, text: true #AlwaysActive
#
# DateTime :created_at, null: false
# DateTime :updated_at, null: false

#
# # frozen_string_literal: true
#
# module Settings
#   module Products
#     module Product
#       class New
#         def self.call(form_values: nil, form_errors: nil, remote: true) # rubocop:disable Metrics/AbcSize
#           ui_rule = UiRules::Compiler.new(:product, :new, form_values: form_values)
#           rules   = ui_rule.compile
#
#           layout = Crossbeams::Layout::Page.build(rules) do |page|
#             page.form_object ui_rule.form_object
#             page.form_values form_values
#             page.form_errors form_errors
#             page.form do |form|
#               form.action '/settings/products/products'
#               form.remote! if remote
#               form.add_field :product_type_id
#             end
#           end
#
#           layout
#         end
#       end
#     end
#   end
# end
