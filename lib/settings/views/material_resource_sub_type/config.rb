# frozen_string_literal: true

module Settings
  module PackMaterialProducts
    module MaterialResourceSubType
      class Config
        def self.call(id, form_values = nil, form_errors = nil)
          ui_rule = UiRules::Compiler.new(:material_resource_sub_type, :config, id: id, form_values: form_values)
          rules = ui_rule.compile

          # TODO: transform form_values...
          p "CONF: Fvals: #{form_values}"
          order_rule = UiRules::Compiler.new(:mr_config_order, :config_order, id: id, form_values: form_values)
          rules_for_cols = order_rule.compile

          repo = PackMaterialRepo.new
          config = repo.find_material_resource_type_config_for_sub_type(id)

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors

            page.section do |section|
              section.add_text "Config for #{config.domain_name}: #{config.type_name}, #{config.sub_type_name}", wrapper: :h2
              section.form do |form|
                form.action "/settings/pack_material_products/material_resource_sub_types/#{id}/config"
                form.remote!
                form.method :update
                form.add_field :material_resource_sub_type_id
                form.add_field :product_code_separator
                form.add_field :has_suppliers
                form.add_field :has_marketers
                form.add_field :has_retailer
                form.add_field :active

                form.submit_captions 'Update config'
              end
            end

            # Product Columns
            page.section do |section|
              section.row do |row|
                row.column do |col|
                  col.add_text 'Assign Product Columns'
                  col.add_grid('productColumnsGrid',
                               '/list/material_resource_product_columns/grid_multi/material_resource_type_configs',
                               caption: 'Assign Product Columns',
                               is_multiselect: true,
                               multiselect_url: "/settings/pack_material_products/link_mr_product_columns/#{config.id}",
                               multiselect_key: 'material_resource_type_config',
                               multiselect_params: { id: config.id }, # variant_bool: false},
                               can_be_cleared: true,
                               multiselect_save_remote: true)
                end
              end
            end

            page.section do |section|
              section.form do |form|
                # options = repo.for_select_non_variant_product_code_column_ids(config.id)
                # # p 'options', options
                # selected = config.for_selected_non_variant_product_code_column_ids
                # # p 'selected', selected
                # var_options = repo.for_select_variant_product_code_column_ids(config.id)
                # # p 'var_options', var_options
                # var_selected = config.for_selected_variant_product_code_column_ids
                # # p 'var_selected', var_selected
                form.form_config = rules_for_cols
                # form.form_config = {
                #   name: 'product_code_columns',
                #   fields: {
                #     chosen_column_ids: { renderer: :hidden },
                #     non_variant_product_code_column_ids: {
                #       renderer: :multi,
                #       options: options,
                #       selected: selected
                #     },
                #     variant_product_code_column_ids: {
                #       renderer: :multi,
                #       options: var_options,
                #       selected: var_selected
                #     }
                #   },
                #   behaviours: [
                #     non_variant_product_code_column_ids: {
                #       populate_from_selected: [{ sortable: 'columncodes-sortable-items' }]
                #     },
                #     variant_product_code_column_ids: {
                #       populate_from_selected: [{ sortable: 'variantcolumncodes-sortable-items' }]
                #     }
                #   ]
                # }
                non_variant_name_list = repo.non_variant_product_code_column_name_list(id)
                variant_name_list = repo.variant_product_code_column_name_list(id)
                form.form_object order_rule.form_object
                # form.form_object OpenStruct.new(non_variant_product_code_column_ids: [],
                #                                 chosen_column_ids: (options + var_options).join(','))
                form.action "/settings/pack_material_products/assign_product_code_columns/#{config.id}"
                # form.action "/settings/pack_material_products/reorder_variant_product_code_columns/#{id}"
                form.method :create
                # form.remote!
                form.row do |row|
                  row.column do |col|
                    col.add_field :chosen_column_ids
                    col.add_field :non_variant_product_code_column_ids
                  end
                  row.column do |col|
                    col.add_sortable_list('columncodes', non_variant_name_list, caption: 'Order columns for code')
                  end
                end
                form.row do |row|
                  row.column do |col|
                    col.add_field :variant_product_code_column_ids
                  end
                  row.column do |col|
                    col.add_sortable_list('variantcolumncodes', variant_name_list, caption: 'Order variant columns')
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
