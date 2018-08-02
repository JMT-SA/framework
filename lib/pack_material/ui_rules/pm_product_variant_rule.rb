# frozen_string_literal: true

module UiRules
  class PmProductVariantRule < Base
    def generate_rules
      @repo = PackMaterialApp::PmProductRepo.new
      @config_repo = PackMaterialApp::ConfigRepo.new
      @commodity_repo = MasterfilesApp::CommodityRepo.new
      @variety_repo = MasterfilesApp::CultivarRepo.new

      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'pm_product_variant'
    end

    def set_show_fields
      pm_product_id_label = @repo.find_pm_product(product_id)&.product_code
      fields[:pack_material_product] = { renderer: :label, with_value: pm_product_id_label, caption: 'Product' }
      fields[:pack_material_product_id] = { renderer: :hidden, value: product_id }
      fields[:commodity_id] = { renderer: :label, with_value: @form_object.commodity_id ? commodity_id_label : nil, caption: 'Commodity' }
      fields[:marketing_variety_id] = { renderer: :label, with_value: @form_object.marketing_variety_id ? variety_id_label : nil, caption: 'Variety' }
      fields[:product_variant_number] = { renderer: :label }
      fields[:unit] = { renderer: :label }
      fields[:style] = { renderer: :label }
      fields[:alternate] = { renderer: :label }
      fields[:shape] = { renderer: :label }
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
      fields[:pm_class] = { renderer: :label }
      fields[:grade] = { renderer: :label }
      fields[:language] = { renderer: :label }
      fields[:other] = { renderer: :label }
    end

    def common_fields
      pm_product_id_label = @repo.find_pm_product(product_id)&.product_code
      x = {
        pack_material_product: { renderer: :label, with_value: pm_product_id_label, caption: 'Product', readonly: true },
        pack_material_product_id: { renderer: :hidden, with_value: product_id },
        product_variant_number: {}
      }

      product_column_set.each do |col_name, required|
        list = master_list_items(col_name)
        list = @commodity_repo.for_select_commodities if col_name == :commodity_id
        list = @variety_repo.for_select_marketing_varieties if col_name == :marketing_variety_id

        caption = col_name.to_s.gsub('_id', '').gsub('pm_', '').gsub('_', ' ').capitalize
        caption = 'Variety' if col_name == :marketing_variety_id

        x[col_name] = list.any? ? { renderer: :select, options: list, caption: caption, required: required } : { required: required }
      end
      x
    end

    def product_id
      @form_object.pack_material_product_id || @options[:parent_id]
    end

    def product_column_set
      product = @repo.find_pm_product(product_id)
      applicable_columns = @config_repo.product_variant_columns(product.material_resource_sub_type_id).map { |r| r.push(true) }
      applicable_columns_optional = @config_repo.product_variant_columns_optional(product.material_resource_sub_type_id).map { |r| r.push(false) }
      combined_set = applicable_columns + applicable_columns_optional
      combined_set.map { |r| [r[0].to_sym, r[2]] }
    end

    def master_list_items(product_column)
      product = @repo.find_pm_product(product_id)
      @config_repo.for_select_sub_type_master_list_items(product.material_resource_sub_type_id, product_column)
    end

    def variety_id_label
      @variety_repo.find_marketing_variety(@form_object.marketing_variety_id)&.marketing_variety_code
    end

    def commodity_id_label
      @commodity_repo.find_commodity(@form_object.commodity_id)&.code
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_pm_product_variant(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(pack_material_product_id: nil,
                                    product_variant_number: nil,
                                    unit: nil,
                                    style: nil,
                                    alternate: nil,
                                    shape: nil,
                                    reference_size: nil,
                                    reference_dimension: nil,
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
                                    other: nil)
    end
  end
end
