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

      common_values_for_fields @mode == :new ? new_fields : edit_fields

      set_show_fields if @mode == :show

      form_name 'pm_product'
    end

    def set_show_fields
      material_resource_sub_type_id_label = @config_repo.find_matres_sub_type(@form_object.material_resource_sub_type_id)&.sub_type_name
      fields[:material_resource_sub_type_id] = { renderer: :label, with_value: material_resource_sub_type_id_label, caption: 'Sub Type' }
      commodity_id_label = @commodity_repo.find_commodity(@form_object.commodity_id)&.code
      fields[:commodity_id] = { renderer: :label, with_value: commodity_id_label, caption: 'commodity' }
      variety_id_label = @variety_repo.find_marketing_variety(@form_object.variety_id)&.marketing_variety_code
      fields[:variety_id] = { renderer: :label, with_value: variety_id_label, caption: 'variety' }
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
      fields[:specification_notes] = { renderer: :label }
    end

    def new_fields
      {
        material_resource_sub_type_id: { renderer: :select, options: @config_repo.for_select_matres_sub_types, caption: 'Sub Type', required: true },
        commodity_id: { renderer: :select, options: @commodity_repo.for_select_commodities, caption: 'Commodity' },
        variety_id: { renderer: :select, options: @variety_repo.for_select_marketing_varieties, caption: 'Variety' },
        specification_notes: { renderer: :text }
      }
    end

    def edit_fields
      material_resource_sub_type_id_label = @config_repo.find_matres_sub_type(@form_object.material_resource_sub_type_id)&.sub_type_name
      x = {
        material_resource_sub_type_name: { renderer: :label, with_value: material_resource_sub_type_id_label, caption: 'Sub Type', readonly: true },
        material_resource_sub_type_id: { renderer: :hidden, with_value: @form_object.material_resource_sub_type_id },
        commodity_id: { renderer: :select, options: @commodity_repo.for_select_commodities, caption: 'Commodity' },
        variety_id: { renderer: :select, options: @variety_repo.for_select_marketing_varieties, caption: 'Variety' },
        specification_notes: { renderer: :text }
      }

      product_column_set.each do |col_name|
        list = master_list_items(col_name)
        x[col_name] = list.any? ? { renderer: :select, options: list, caption: col_name.to_s.gsub('pm_', '').gsub('_', ' ').capitalize  } : {}
      end
      x
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_pm_product(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(material_resource_sub_type_id: nil,
                                    commodity_id: nil,
                                    variety_id: nil,
                                    specification_notes: nil)
    end

    def product_column_set
      applicable_columns = @config_repo.product_code_columns(@form_object[:material_resource_sub_type_id])
      applicable_columns.map { |r| r[0].to_sym }
    end

    def master_list_items(product_column)
      @config_repo.for_select_sub_type_master_list_items(@form_object[:material_resource_sub_type_id], product_column)
    end
  end
end
