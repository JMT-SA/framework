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
          grid_def = Crossbeams::DataGrid::ListGridDefinition.new(root_path: ENV['ROOT'],
                                                                  id: 'multi_matres_product_columns',
                                                                  multi_key: 'material_resource_type_configs',
                                                                  params: { id: id, key: 'material_resource_type_configs' })

          layout = Crossbeams::Layout::Page.build(rules) do |page| # rubocop:disable Metrics/BlockLength
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors

            page.section do |section|
              section.add_control(control_type: :link, text: 'Back', url: '/list/material_resource_sub_types', style: :back_button)
            end

            # Product Columns
            page.section do |section|
              section.show_border!
              section.row do |row|
                row.column do |col|
                  col.add_text "Assign Product Columns for <strong>#{rules[:sub_type_text]}</strong>"
                  col.add_grid('productColumnsGrid', grid_def.grid_path, grid_def.render_options)
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

                form.row do |row|
                  row.column do |col|
                    col.add_field :variant_product_code_column_ids
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
