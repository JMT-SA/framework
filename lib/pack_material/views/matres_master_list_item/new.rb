# frozen_string_literal: true

module PackMaterial
  module Config
    module MatresMasterListItem
      class New
        def self.call(sub_type_id, product_column_id, form_values: nil, form_errors: nil, remote: true) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:matres_master_list_item, :new, product_column_id: product_column_id, sub_type_id: sub_type_id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/pack_material/config/material_resource_sub_types/#{sub_type_id}/material_resource_master_list_items"
              form.remote! if remote
              form.form_id 'new_mrli_item'
              form.add_field :material_resource_product_column_name
              form.add_field :material_resource_product_column_id
              form.add_field :short_code
              form.add_field :long_name
              form.add_field :description
              form.add_field :list_items

              form.submit_captions 'Add', 'Adding'
            end
            page.section do |section|
              section.add_control(control_type: :link, text: 'Done', url: "/pack_material/config/material_resource_sub_types/#{sub_type_id}/product_columns", style: :button)
            end
          end

          layout
        end
      end
    end
  end
end
