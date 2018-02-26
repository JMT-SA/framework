# frozen_string_literal: true

module Settings
  module PackMaterialProducts
    module PackMaterialProduct
      class Edit
        def self.call(id, form_values = nil, form_errors = nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:pack_material_product, :edit, id: id, form_values: form_values)
          rules = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/settings/pack_material_products/pack_material_products/#{id}"
              form.method :update

            end
          end

          layout
        end
      end
    end
  end
end



# frozen_string_literal: true

module Settings
  module Products
    module Product
      class Edit
        def self.call(id, form_values = nil, form_errors = nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:product, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile
          product_column_options = ProductTypeRepo.new.product_column_options(id)

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/settings/products/products/#{id}"
              form.remote!
              form.method :update
              form.add_field :product_type_id
              form.add_field :active

              product_column_options.keys.each do |key|
                form.add_text "<b>#{ key.to_s.capitalize.gsub('_', ' ') }</b>"
                product_column_options[key].keys.each do |sub|
                  form.add_field :"#{sub}"

                end
              end
            end
          end

          layout
        end
      end
    end
  end
end
