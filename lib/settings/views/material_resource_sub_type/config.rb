# frozen_string_literal: true

module Settings
  module PackMaterialProducts
    module MaterialResourceSubType
      class Config
        def self.call(id, form_values = nil, form_errors = nil)
          ui_rule = UiRules::Compiler.new(:material_resource_sub_type, :config, id: id, form_values: form_values)
          rules = ui_rule.compile
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
                # form.add_field :product_code_column_ids # TODO: if I put it here it works?
                form.add_field :active

                form.submit_captions "Update config"
              end
            end

            # Product Columns
            page.section do |section|
              section.add_text 'Assign Product Columns'
              section.add_grid('productColumnsGrid',
                               '/list/material_resource_product_columns/grid_multi/material_resource_type_configs',
                               caption: 'Assign Product Columns',
                               is_multiselect: true,
                               multiselect_url: "/settings/pack_material_products/link_mr_product_columns/#{config.id}",
                               multiselect_key: 'material_resource_type_config',
                               multiselect_params: { id: config.id },# variant_bool: false},
                               can_be_cleared: true,
                               multiselect_save_remote: false)
            end

            # TODO: the following two sections need to be one form and in two columns
            page.section do |section|
              section.form do |form|
                options = repo.for_select_non_variant_product_code_column_ids(config.id)
                p 'options', options
                selected = config.for_selected_non_variant_product_code_column_ids
                p 'selected', selected
                form.form_config = {
                  name: 'product_code_columns',
                  fields: {
                    non_variant_product_code_column_ids: { renderer: :multi, options: options, selected: selected }
                  }
                }
                form.form_object OpenStruct.new(non_variant_product_code_column_ids: [])
                form.action "/settings/pack_material_products/assign_product_code_columns/#{config.id}"
                form.method :create
                form.remote!
                form.add_field :non_variant_product_code_column_ids
                # form.submit_captions 'Save', 'Saving'
              end
            end

            page.section do |section|
              product_code_column_name_list = repo.product_code_column_name_list(id)
              section.form do |form|
                form.action "/settings/pack_material_products/reorder_product_code_columns/#{id}"
                form.add_text 'Drag and drop to set the Product code column order. Press submit to save the new order.'
                form.add_sortable_list('columncodes', product_code_column_name_list)
              end
            end

            # TODO: the following two sections need to be one form and in two columns
            page.section do |section|
              section.form do |form|
                form.form_config = {
                  name: 'product_variant_code_columns',
                  fields: {
                    variant_product_code_column_ids: { renderer: :multi, options: repo.for_select_variant_product_code_column_ids(config.id), selected: config.for_selected_variant_product_code_column_ids }
                  }
                }
                form.form_object OpenStruct.new(variant_product_code_column_ids: [])#OpenStruct.new(path: path, value: Base64.encode64(code))
                form.action '/development/generators/scaffolds/save_snippet' # TODO: fix url
                form.method :update
                form.remote!
                form.add_field :variant_product_code_column_ids
                # form.submit_captions 'Save', 'Saving'
              end
            end

            page.section do |section|
              product_code_column_name_list = repo.product_code_column_name_list(id)
              section.form do |form|
                # TODO: This still needs to be applied for variants  -THIS IS A COPY
                form.action "/settings/pack_material_products/reorder_product_code_columns/#{id}"
                form.add_text 'Drag and drop to set the Product code column order. Press submit to save the new order.'
                form.add_sortable_list('columncodes', product_code_column_name_list)
              end
            end

            # product_column_ids = repo.mr_type_mr_product_column_ids(config.id)
            # product_column_ids = repo.non_variant_product_column_ids(config.id)
            # if product_column_ids.any?
              # page.section do |section|
              #   section.form do |form|
              #     form.add_field :product_code_column_ids
              #     form.add_field :product_variant_code_column_ids
              #   end
              # end


              # page.section do |section|
              #   section.add_grid('productCodeColumnsGrid',
              #                    '/list/material_resource_product_code_columns/grid_multi/material_resource_type_configs',
              #                    caption: 'Assign Product Code Columns',
              #                    is_multiselect: true,
              #                    multiselect_url: "/settings/pack_material_products/link_mr_product_code_columns/#{config.id}",
              #                    multiselect_key: 'material_resource_type_configs',
              #                    multiselect_params: { id: config.id, variant_bool: false, product_column_ids: "#{product_column_ids.join(',')}" },
              #                    can_be_cleared: true,
              #                    multiselect_save_remote: false)
              # end
              #
              # page.section do |section|
              #   product_code_column_name_list = repo.product_code_column_name_list(id)
              #   section.form do |form|
              #     form.action "/settings/pack_material_products/reorder_product_code_columns/#{id}"
              #     form.add_text 'Drag and drop to set the Product code column order. Press submit to save the new order.'
              #     form.add_sortable_list('columncodes', product_code_column_name_list)
              #   end
              # end
            # end

            # SORTABLE LIST
            # product_code_column_name_list = repo.product_code_column_name_list(id)
            #
            # layout = Crossbeams::Layout::Page.build do |page|
            #   page.form do |form|
            #     form.action "/settings/products/reorder_product_code_column_names/#{id}"
            #     form.remote!
            #     form.add_text 'Drag and drop to set the Product code column order. Press submit to save the new order.'
            #     form.add_sortable_list('columncodes', product_code_column_name_list)
            #   end
            # end



            #
            # # Variant Product Columns
            # # TODO: To add this in here you need to redo the way linking is done as the repo expects the whole set not a partial set
            # page.section do |section|
            # #   section.add_text 'Assign Variant Product Columns'
            #   section.add_grid('productColumnsGrid',
            #                    '/list/material_resource_product_columns/grid_multi/material_resource_type_configs',
            #                    caption: 'Assign Variant Product Columns',
            #                    is_multiselect: true,
            #                    multiselect_url: "/settings/pack_material_products/link_mr_product_columns/#{config.id}",
            #                    multiselect_key: 'material_resource_type_config',
            #                    multiselect_params: { id: config.id, variant_bool: true },
            #                    can_be_cleared: true,
            #                    multiselect_save_remote: false)
            # end
            #
            # # variant_product_column_ids = repo.mr_type_mr_product_column_ids(config.id)
            # variant_product_column_ids = repo.variant_product_column_ids(config.id)
            # page.section do |section|
            #   section.add_grid('productCodeColumnsGrid',
            #                    '/list/material_resource_product_code_columns/grid_multi/material_resource_type_configs',
            #                    caption: 'Assign Variant Product Code Columns',
            #                    is_multiselect: true,
            #                    multiselect_url: "/settings/pack_material_products/link_mr_product_code_columns/#{config.id}",
            #                    multiselect_key: 'material_resource_type_configs',
            #                    multiselect_params: { id: config.id, variant_bool: true, product_column_ids: "#{variant_product_column_ids.join(',')}" },
            #                    can_be_cleared: true,
            #                    multiselect_save_remote: false)
            # end
            #
            # page.section do |section|
            #   product_code_column_name_list = repo.product_code_column_name_list(id)
            #   section.form do |form|
            #     form.action "/settings/pack_material_products/reorder_product_code_columns/#{id}"
            #     form.add_text 'Drag and drop to set the Product code column order. Press submit to save the new order.'
            #     form.add_sortable_list('columncodes', product_code_column_name_list)
            #   end
            # end
          end

          layout
        end
      end
    end
  end
end