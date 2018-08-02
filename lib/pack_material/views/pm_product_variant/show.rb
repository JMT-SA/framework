# frozen_string_literal: true

module PackMaterial
  module Config
    module PmProductVariant
      class Show
        def self.call(id) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:pm_product_variant, :show, id: id)
          rules   = ui_rule.compile
          pm_product_id = ui_rule.form_object.pack_material_product_id

          # Consider view helper per App
          product = PackMaterialApp::PmProductRepo.new.find_pm_product(pm_product_id)
          set = PackMaterialApp::ConfigRepo.new.product_variant_columns(product.material_resource_sub_type_id).map { |r| r[0].to_sym }

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :pack_material_product
              form.add_field :product_variant_number

              set.each do |item|
                form.add_field item
              end
            end
          end

          layout
        end
      end
    end
  end
end
