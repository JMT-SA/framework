# frozen_string_literal: true

module PackMaterial
  module Config
    module MatresMasterListItem
      class Preselect
        def self.call(sub_type_id, form_values: nil, form_errors: nil, remote: true)
          ui_rule = UiRules::Compiler.new(:matres_master_list_item, :preselect, sub_type_id: sub_type_id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/pack_material/config/material_resource_sub_types/#{sub_type_id}/material_resource_master_list_items/new"
              form.remote! if remote
              form.add_field :material_resource_product_column_id
            end
          end

          layout
        end
      end
    end
  end
end
