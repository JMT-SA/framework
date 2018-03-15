# frozen_string_literal: true

module PackMaterialApp
  module Config
    module PmProduct
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:pm_product, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :material_resource_sub_type_id
              form.add_field :product_number
              form.add_field :description
              form.add_field :commodity_id
              form.add_field :variety_id
              form.add_field :style
              form.add_field :assembly_type
              form.add_field :market_major
              form.add_field :ctn_size_basic_pack
              form.add_field :ctn_size_old_pack
              form.add_field :pls_pack_code
              form.add_field :fruit_mass_nett_kg
              form.add_field :holes
              form.add_field :perforation
              form.add_field :image
              form.add_field :length_mm
              form.add_field :width_mm
              form.add_field :height_mm
              form.add_field :diameter_mm
              form.add_field :thick_mm
              form.add_field :thick_mic
              form.add_field :colour
              form.add_field :grade
              form.add_field :mass
              form.add_field :material_type
              form.add_field :treatment
              form.add_field :specification_notes
              form.add_field :artwork_commodity
              form.add_field :artwork_marketing_variety_group
              form.add_field :artwork_variety
              form.add_field :artwork_nett_mass
              form.add_field :artwork_brand
              form.add_field :artwork_class
              form.add_field :artwork_plu_number
              form.add_field :artwork_other
              form.add_field :artwork_image
              form.add_field :marketer
              form.add_field :retailer
              form.add_field :supplier
              form.add_field :supplier_stock_code
              form.add_field :product_alternative
              form.add_field :product_joint_use
              form.add_field :ownership
              form.add_field :consignment_stock
              form.add_field :start_date
              form.add_field :end_date
              form.add_field :remarks
            end
          end

          layout
        end
      end
    end
  end
end
