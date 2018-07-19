# frozen_string_literal: true

module PackMaterial
  module Config
    module PmProductVariant
      class Clone
        def self.call(id, form_values = nil, form_errors = nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:pm_product_variant, :clone, id: id, form_values: form_values)
          rules   = ui_rule.compile
          pm_product_id = ui_rule.form_object.pack_material_product_id

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/pack_material/config/pack_material_products/#{pm_product_id}/pack_material_product_variants/clone/#{id}"
              form.remote!
              form.add_field :pack_material_product
              form.add_field :pack_material_product_id

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
