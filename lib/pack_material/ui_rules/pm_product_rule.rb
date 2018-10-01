# frozen_string_literal: true

module UiRules
  class PmProductRule < Base
    def generate_rules
      @repo = PackMaterialApp::PmProductRepo.new
      @config_repo = PackMaterialApp::ConfigRepo.new
      @commodity_repo = MasterfilesApp::CommodityRepo.new
      @variety_repo = MasterfilesApp::CultivarRepo.new

      make_form_object
      apply_form_values

      common_values_for_fields @mode == :preselect ? preselect_fields : edit_fields

      set_show_fields if @mode == :show

      form_name 'pm_product'
    end

    def set_show_fields
      material_resource_sub_type_id_label = @config_repo.find_matres_sub_type(@form_object.material_resource_sub_type_id)&.sub_type_name
      fields[:material_resource_sub_type_id] = { renderer: :label, with_value: material_resource_sub_type_id_label, caption: 'Sub Type' }
      fields[:commodity_id] = { renderer: :label, with_value: @form_object.commodity_id ? commodity_id_label : nil, caption: 'Commodity' }
      fields[:marketing_variety_id] = { renderer: :label, with_value: @form_object.marketing_variety_id ? variety_id_label : nil, caption: 'Variety' }
      fields[:product_number] = { renderer: :label }
      fields[:product_code] = { renderer: :label }
      fields[:unit] = { renderer: :label }
      fields[:style] = { renderer: :label }
      fields[:alternate] = { renderer: :label }
      fields[:shape] = { renderer: :label, caption: 'Shape' }
      fields[:reference_size] = { renderer: :label }
      fields[:reference_dimension] = { renderer: :label }
      fields[:reference_quantity] = { renderer: :label }
      fields[:brand_1] = { renderer: :label }
      fields[:brand_2] = { renderer: :label }
      fields[:colour] = { renderer: :label }
      fields[:material] = { renderer: :label }
      fields[:assembly] = { renderer: :label }
      fields[:reference_mass] = { renderer: :label }
      fields[:reference_number] = { renderer: :label }
      fields[:market] = { renderer: :label }
      fields[:marking] = { renderer: :label }
      fields[:model] = { renderer: :label }
      fields[:pm_class] = { renderer: :label, caption: 'Class' }
      fields[:grade] = { renderer: :label }
      fields[:language] = { renderer: :label }
      fields[:other] = { renderer: :label }
    end

    def preselect_fields
      {
        material_resource_sub_type_id: { renderer: :select,
                                         options: @config_repo.for_select_configured_sub_types(PackMaterialApp::DOMAIN_NAME),
                                         caption: 'Please select Sub Type',
                                         required: true }
      }
    end

    def edit_fields
      material_resource_sub_type_id_label = @config_repo.find_matres_sub_type(@form_object[:material_resource_sub_type_id])&.sub_type_name
      x = {
        material_resource_sub_type_name: { renderer: :label, with_value: material_resource_sub_type_id_label, caption: 'Sub Type', readonly: true },
        material_resource_sub_type_id: { renderer: :hidden, with_value: @form_object.material_resource_sub_type_id }
      }

      product_column_set.each do |col_name|
        list = master_list_items(col_name)
        list = @commodity_repo.for_select_commodities if col_name == :commodity_id
        list = @variety_repo.for_select_marketing_varieties if col_name == :marketing_variety_id

        caption = col_name.to_s.gsub('_id', '').gsub('pm_', '').tr('_', ' ').capitalize
        caption = 'Variety' if col_name == :marketing_variety_id

        x[col_name] = list.any? ? { renderer: :select, options: list, caption: caption, required: true } : { required: true }
      end
      x
    end

    def make_form_object
      make_preselect_form_object && return if @mode == :preselect
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_pm_product(@options[:id])
    end

    def make_preselect_form_object
      @form_object = OpenStruct.new(material_resource_sub_type_id: nil)
    end

    def make_new_form_object
      @form_object = OpenStruct.new(material_resource_sub_type_id: @options[:sub_type_id],
                                    commodity_id: nil,
                                    marketing_variety_id: nil,
                                    product_number: nil,
                                    product_code: nil,
                                    unit: nil,
                                    style: nil,
                                    alternate: nil,
                                    shape: nil,
                                    reference_size: nil,
                                    reference_quantity: nil,
                                    brand_1: nil,
                                    brand_2: nil,
                                    colour: nil,
                                    material: nil,
                                    assembly: nil,
                                    reference_mass: nil,
                                    reference_number: nil,
                                    market: nil,
                                    marking: nil,
                                    model: nil,
                                    pm_class: nil,
                                    grade: nil,
                                    language: nil,
                                    other: nil,
                                    reference_dimension: nil)
    end

    def product_column_set
      applicable_columns = @config_repo.product_code_columns(@form_object[:material_resource_sub_type_id])
      applicable_columns.map { |r| r[0].to_sym }
    end

    def master_list_items(product_column)
      @config_repo.for_select_sub_type_master_list_items(@form_object[:material_resource_sub_type_id], product_column)
    end

    def variety_id_label
      @variety_repo.find_marketing_variety(@form_object.marketing_variety_id)&.marketing_variety_code
    end

    def commodity_id_label
      @commodity_repo.find_commodity(@form_object.commodity_id)&.code
    end
  end
end
