# frozen_string_literal: true

module PackMaterial
  module Config
    module PmProductVariant
      class New
        def self.call(parent_id, form_values: nil, form_errors: nil, remote: true) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:pm_product_variant, :new, parent_id: parent_id, form_values: form_values)
          rules   = ui_rule.compile

          # Consider view helper per App
          product = PackMaterialApp::PmProductRepo.new.find_pm_product(parent_id)
          set = PackMaterialApp::ConfigRepo.new.product_variant_columns(product.material_resource_sub_type_id).map { |r| r[0].to_sym }

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/pack_material/config/pack_material_products/#{parent_id}/pack_material_product_variants"
              form.remote! if remote
              form.add_field :pack_material_product
              form.add_field :pack_material_product_id

              set.each do |item|
                form.add_field item
              end

              form.add_field :specification_reference
            end
          end

          layout
        end
      end
    end
  end
end
