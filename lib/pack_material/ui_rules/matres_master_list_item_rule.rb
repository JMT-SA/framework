# frozen_string_literal: true

module UiRules
  class MatresMasterListItemRule < Base
    def generate_rules
      @repo = PackMaterialApp::ConfigRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields @mode == :preselect ? preselect_fields : common_fields

      form_name 'matres_master_list_item'
    end

    def preselect_fields
      product_columns = @repo.product_columns(@options[:sub_type_id]).reject { |r|  r[0] == 'commodity_id' || r[0] == 'marketing_variety_id' }
      common_fields.merge(
        material_resource_product_column_id: { renderer: :select, options: product_columns, caption: 'Please select Product Column', required: true }
      )
    end

    def common_fields
      product_column_id = @options[:product_column_id]
      prodcol_label = @repo.find_matres_product_column(product_column_id)&.column_name
      {
        material_resource_product_column_name: { renderer: :label, with_value: prodcol_label, caption: 'Product Column', readonly: true },
        material_resource_product_column_id: { renderer: :hidden, value: product_column_id },
        short_code: { required: true, force_uppercase: true },
        long_name: {},
        description: {},
        active: { renderer: :checkbox },
        list_items: { renderer: :list, items: list_items, caption: 'Master List Items' }
      }
    end

    def make_form_object
      make_preselect_form_object && return if @mode == :preselect
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_matres_master_list_item(@options[:id])
    end

    def make_preselect_form_object
      @form_object = OpenStruct.new(material_resource_sub_type_id: nil)
    end

    def make_new_form_object
      @form_object = OpenStruct.new(material_resource_master_list_id: nil,
                                    material_resource_product_column_id: @options[:product_column_id],
                                    short_code: nil,
                                    long_name: nil,
                                    description: nil)
    end

    def list_items
      items = @repo.matres_sub_type_master_list_items(@options[:sub_type_id], @options[:product_column_id])
      items.map { |r| "#{r[:short_code]} #{r[:long_name] ? '- ' + r[:long_name] : ''}" }
    end
  end
end
