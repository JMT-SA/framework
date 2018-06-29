# frozen_string_literal: true

module PackMaterial
  module Config
    module MatresSubType
      class Config
        def self.call(id, form_values: nil, form_errors: nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:matres_sub_type, :config, id: id, form_values: form_values)
          rules   = ui_rule.compile

          order_rule = UiRules::Compiler.new(:matres_sub_type_columns, :config_order, id: id, form_values: form_values)
          rules_for_cols = order_rule.compile

          repo = PackMaterialApp::ConfigRepo.new

          layout = Crossbeams::Layout::Page.build(rules) do |page| # rubocop:disable Metrics/BlockLength
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors

            page.section do |section|
              # section.add_text "Config for #{ui_rule.form_object.sub_type_name}", wrapper: :h2
              section.add_caption "Config for #{ui_rule.form_object.sub_type_name}"
              section.show_border!
              section.form do |form|
                form.action "/pack_material/config/material_resource_sub_types/#{id}/config"
                form.remote!
                form.method :update
                form.add_field :product_code_separator
                form.add_field :has_suppliers
                form.add_field :has_marketers
                form.add_field :has_retailers
                # form.add_field :active

                form.submit_captions 'Update config'
              end
            end

            # Product Columns
            page.section do |section|
              section.show_border!
              section.row do |row|
                row.column do |col|
                  col.add_text 'Assign Product Columns'
                  col.add_grid('productColumnsGrid',
                               '/list/multi_matres_product_columns/grid_multi/material_resource_type_configs',
                               caption: 'Assign Product Columns',
                               is_multiselect: true,
                               multiselect_url: "/pack_material/config/link_product_columns/#{id}",
                               multiselect_key: 'material_resource_type_config',
                               multiselect_params: { id: id },
                               can_be_cleared: true,
                               multiselect_save_method: 'remote')
                end
              end
            end

            page.section do |section|
              section.show_border!
              section.form do |form|
                form.form_config = rules_for_cols
                product_code_column_name_list = repo.product_code_columns(id)
                form.form_object order_rule.form_object
                form.form_errors(form_errors&.transform_keys { |k| k == :columncodes_sorted_ids ? :product_code_column_ids : k })
                form.action "/pack_material/config/material_resource_sub_types/#{id}/update_product_code_configuration"

                form.row do |row|
                  row.column do |col|
                    col.add_field :chosen_column_ids
                    col.add_field :product_code_column_ids
                  end
                  row.column do |col|
                    col.add_sortable_list('columncodes', product_code_column_name_list, caption: 'Drag columns to set order for first part of code')
                  end
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
