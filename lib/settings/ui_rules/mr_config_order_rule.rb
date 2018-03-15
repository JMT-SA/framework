# frozen_string_literal: true

module UiRules
  class MrConfigOrderRule < Base
    def generate_rules
      @repo = PackMaterialRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      add_behaviours

      form_name 'product_code_columns'
    end

    def common_fields
      config = @repo.find_material_resource_type_config_for_sub_type(@options[:id])
      options = @repo.for_select_non_variant_product_code_column_ids(@options[:id])
      var_options = @repo.for_select_variant_product_code_column_ids(@options[:id])
      selected = config.for_selected_non_variant_product_code_column_ids
      var_selected = config.for_selected_variant_product_code_column_ids
      {
        chosen_column_ids: { renderer: :hidden },
        non_variant_product_code_column_ids: {
          renderer: :multi, options: options, selected: selected
        },
        variant_product_code_column_ids: {
          renderer: :multi, options: var_options, selected: var_selected
        }
      }
    end

    def make_form_object
      # @form_object = @repo.find_material_resource_type_config_for_sub_type(@options[:id])
      # TODO: this can all be moved into the repo...
      options = @repo.for_select_non_variant_product_code_column_ids(@options[:id])
      var_options = @repo.for_select_variant_product_code_column_ids(@options[:id])
      @form_object = OpenStruct.new(non_variant_product_code_column_ids: options,
                                    variant_product_code_column_ids: var_options,
                                    chosen_column_ids: (options + var_options).join(','))
    end

    def add_behaviours
      behaviours do |behaviour|
        behaviour.populate_from_selected :non_variant_product_code_column_ids, populate_from_selected: [{ sortable: 'columncodes-sortable-items' }]
        behaviour.populate_from_selected :variant_product_code_column_ids, populate_from_selected: [{ sortable: 'variantcolumncodes-sortable-items' }]
      end
    end
  end
end
