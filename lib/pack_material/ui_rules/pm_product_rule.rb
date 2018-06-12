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

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'pm_product'
    end

    def set_show_fields
      material_resource_sub_type_id_label = @config_repo.find_matres_sub_type(@form_object.material_resource_sub_type_id)&.sub_type_name
      commodity_id_label = @commodity_repo.find_commodity(@form_object.commodity_id)&.code
      variety_id_label = @variety_repo.find_marketing_variety(@form_object.variety_id)&.marketing_variety_code
      fields[:material_resource_sub_type_id] = { renderer: :label, with_value: material_resource_sub_type_id_label, caption: 'Sub Type' }
      fields[:commodity_id] = { renderer: :label, with_value: commodity_id_label, caption: 'commodity' }
      fields[:variety_id] = { renderer: :label, with_value: variety_id_label, caption: 'variety' }
      fields[:product_number] = { renderer: :label }
      fields[:product_code] = { renderer: :label }
      fields[:unit] = { renderer: :label }
      fields[:style] = { renderer: :label }
      fields[:alternate] = { renderer: :label }
      fields[:shape] = { renderer: :label, caption: 'Shape' }
      fields[:reference_size] = { renderer: :label }
      fields[:reference_quantity] = { renderer: :label }
      fields[:length_mm] = { renderer: :label }
      fields[:width_mm] = { renderer: :label }
      fields[:height_mm] = { renderer: :label }
      fields[:diameter_mm] = { renderer: :label }
      fields[:thick_mm] = { renderer: :label }
      fields[:thick_mic] = { renderer: :label }
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

    def common_fields
      {
        material_resource_sub_type_id: { renderer: :select, options: @config_repo.for_select_matres_sub_types, caption: 'Sub Type', required: true },
        commodity_id: { renderer: :select, options: @commodity_repo.for_select_commodities, caption: 'Commodity' },
        variety_id: { renderer: :select, options: @variety_repo.for_select_marketing_varieties, caption: 'Variety' },
        product_number: {},
        product_code: {},
        unit: {},
        style: {},
        alternate: {},
        shape: {},
        reference_size: {},
        reference_quantity: {},
        length_mm: { renderer: :numeric },
        width_mm: { renderer: :numeric },
        height_mm: { renderer: :numeric },
        diameter_mm: { renderer: :numeric },
        thick_mm: { renderer: :numeric },
        thick_mic: { renderer: :numeric },
        brand_1: {},
        brand_2: {},
        colour: {},
        material: {},
        assembly: {},
        reference_mass: {},
        reference_number: {},
        market: {},
        marking: {},
        model: {},
        pm_class: { caption: 'Class' },
        grade: {},
        language: {},
        other: {},
        specification_notes: { renderer: :text }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_pm_product(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(material_resource_sub_type_id: nil,
                                    commodity_id: nil,
                                    variety_id: nil,
                                    product_number: nil,
                                    product_code: nil,
                                    unit: nil,
                                    style: nil,
                                    alternate: nil,
                                    format: nil,
                                    reference_size: nil,
                                    reference_quantity: nil,
                                    length_mm: nil,
                                    width_mm: nil,
                                    height_mm: nil,
                                    diameter_mm: nil,
                                    thick_mm: nil,
                                    thick_mic: nil,
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
                                    specification_notes: nil)
    end
  end
end