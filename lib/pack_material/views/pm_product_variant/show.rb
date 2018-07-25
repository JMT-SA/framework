# frozen_string_literal: true

module PackMaterial
  module Config
    module PmProductVariant
      class Show
        def self.call(id) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:pm_product_variant, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :pack_material_product
              form.add_field :product_variant_number

              form.add_field :commodity_id
              form.add_field :marketing_variety_id
              form.add_field :unit
              form.add_field :style
              form.add_field :alternate
              form.add_field :shape
              form.add_field :reference_size
              form.add_field :reference_dimension
              form.add_field :reference_quantity
              form.add_field :brand_1
              form.add_field :brand_2
              form.add_field :colour
              form.add_field :material
              form.add_field :assembly
              form.add_field :reference_mass
              form.add_field :reference_number
              form.add_field :market
              form.add_field :marking
              form.add_field :model
              form.add_field :pm_class
              form.add_field :grade
              form.add_field :language
              form.add_field :other
            end
          end

          layout
        end
      end
    end
  end
end
