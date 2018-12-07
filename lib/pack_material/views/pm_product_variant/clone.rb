# frozen_string_literal: true

module PackMaterial
  module Config
    module PmProductVariant
      class Clone
        def self.call(id, form_values = nil, form_errors = nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:pm_product_variant, :clone, id: id, form_values: form_values)
          rules   = ui_rule.compile

          variant_set = rules[:product_variant_column_set]
          optional_set = rules[:opt_product_variant_column_set]
          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/pack_material/config/pack_material_products/#{rules[:pm_product_id]}/pack_material_product_variants/clone/#{id}"
              form.remote!
              form.add_field :pack_material_product
              form.add_field :pack_material_product_id

              variant_set.each do |item|
                form.add_field item
              end

              optional_set.each do |item|
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
