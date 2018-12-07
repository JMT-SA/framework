# frozen_string_literal: true

module PackMaterial
  module Config
    module PmProductVariant
      class Show
        def self.call(id) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:pm_product_variant, :show, id: id)
          rules   = ui_rule.compile

          variant_set = rules[:product_variant_column_set]
          optional_set = rules[:opt_product_variant_column_set]
          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :pack_material_product
              form.add_field :product_variant_number

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
