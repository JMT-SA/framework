# frozen_string_literal: true

module UiRules
  class MatresSubTypeColumnsRule < Base
    def generate_rules
      @repo = PackMaterialApp::ConfigRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      add_behaviours

      form_name 'product_code_columns'
    end

    def common_fields
      unless @form_object.chosen_column_ids.nil?
        options, var_options = @repo.product_code_column_options(@options[:id], @form_object.product_code_column_ids)
      end
      {
        chosen_column_ids: { renderer: :hidden },
        product_code_column_ids: {
          renderer: :multi, options: options, caption: 'Non-variants'
        },
        variant_product_code_column_ids: {
          renderer: :multi, options: var_options, caption: 'Variants'
        }
      }
    end

    def make_form_object
      sub_type = @repo.find_matres_sub_type(@options[:id])
      options = @repo.product_code_columns(@options[:id]).map { |_, id| id }
      var_options = @repo.product_variant_code_columns(@options[:id]).map { |_, id| id }

      @form_object = OpenStruct.new(product_code_column_ids: options,
                                    variant_product_code_column_ids: var_options,
                                    chosen_column_ids: (sub_type.product_column_ids || []).join(','))
    end

    def add_behaviours
      behaviours do |behaviour|
        behaviour.populate_from_selected :product_code_column_ids, populate_from_selected: [{ sortable: 'columncodes-sortable-items' }]
        url = "/pack_material/config/material_resource_sub_types/#{@options[:id]}/product_code_columns_selected"
        behaviour.dropdown_change :product_code_column_ids, notify: [{ url: url }]
      end
    end
  end
end
