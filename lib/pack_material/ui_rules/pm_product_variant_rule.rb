# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

module UiRules
  class PmProductVariantRule < Base
    def generate_rules
      @repo = PackMaterialApp::PmProductRepo.new
      @config_repo = PackMaterialApp::ConfigRepo.new
      @commodity_repo = MasterfilesApp::CommodityRepo.new
      @variety_repo = MasterfilesApp::CultivarRepo.new

      make_form_object
      apply_form_values

      @sub_type_id = sub_type_id
      rules[:product_variant_column_set] = product_variant_column_set
      rules[:opt_product_variant_column_set] = opt_product_variant_column_set
      rules[:pm_product_id] = product_id

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
      fields[:reference_dimension_2] = { renderer: :label }
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
      fields[:analysis_code] = { renderer: :label }
      fields[:season_year_use] = { renderer: :label }
      fields[:party] = { renderer: :label }
      fields[:specification_reference] = { renderer: :label }
    end

    def common_fields
      pm_product_id_label = @repo.find_pm_product(product_id)&.product_code
      x = {
        pack_material_product: { renderer: :label, with_value: pm_product_id_label, caption: 'Product', readonly: true },
        pack_material_product_id: { renderer: :hidden, with_value: product_id },
        product_variant_number: {},
        specification_reference: {}
      }

      all_fields = product_variant_column_set.map { |r| [r, true] } + opt_product_variant_column_set.map { |r| [r, false] }
      all_fields.each do |col_name, req|
        list = master_list_items(col_name.to_s)
        list = @commodity_repo.for_select_commodities if col_name == :commodity_id
        list = @variety_repo.for_select_marketing_varieties if col_name == :marketing_variety_id

        caption = col_name.to_s.gsub('_id', '').gsub('pm_', '').tr('_', ' ').capitalize
        caption = 'Variety' if col_name == :marketing_variety_id

        x[col_name] = list.any? ? { renderer: :select, options: list, caption: caption, required: req } : { required: req, caption: caption }
      end
      x
    end

    def product_id
      @form_object.pack_material_product_id || @options[:parent_id]
    end

    def sub_type_id
      product = @repo.find_pm_product(product_id)
      product.material_resource_sub_type_id
    end

    def product_variant_column_set
      @config_repo.product_variant_code_columns(@sub_type_id).map { |r| r[0].to_sym }
    end

    def opt_product_variant_column_set
      @config_repo.optional_product_variant_code_columns(@sub_type_id).map { |r| r[0].to_sym }
    end

    def master_list_items(product_column)
      @config_repo.for_select_sub_type_master_list_items(@sub_type_id, product_column)
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
                                    reference_dimension_2: nil,
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
                                    analysis_code: nil,
                                    season_year_use: nil,
                                    party: nil,
                                    specification_reference: nil,
                                    other: nil)
    end
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize
