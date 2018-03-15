# frozen_string_literal: true

module Settings
  module PackMaterialProducts
    module MaterialResourceProductColumn
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:material_resource_product_column, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :material_resource_domain_id
              form.add_field :column_name
              form.add_field :group_name
              form.add_field :is_variant_column
            end
          end

          layout
        end
      end
    end
  end
end
