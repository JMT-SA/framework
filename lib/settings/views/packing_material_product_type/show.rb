# frozen_string_literal: true

module Settings
  module Products
    module PackingMaterialProductType
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:packing_material_product_type, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :packing_material_type_name
            end
          end

          layout
        end
      end
    end
  end
end
