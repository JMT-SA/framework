# frozen_string_literal: true

module UiRules
  class PmProductRule < Base
    def generate_rules
      @repo = PackMaterialApp::PmProductRepo.new
      @config_repo = PackMaterialApp::ConfigRepo.new
      @commodity_repo = CommodityRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'pm_product'
    end

    def set_show_fields
      material_resource_sub_type_id_label = @config_repo.find_material_resource_sub_type(@form_object.material_resource_sub_type_id)&.sub_type_name
      commodity_id_label = @commodity_repo.find_commodity(@form_object.commodity_id)&.code
      fields[:material_resource_sub_type_id] = { renderer: :label, with_value: material_resource_sub_type_id_label, caption: 'material_resource_sub_type' }
      fields[:product_number] = { renderer: :label }
      fields[:description] = { renderer: :label }
      fields[:commodity_id] = { renderer: :label, with_value: commodity_id_label, caption: 'commodity' }
      fields[:variety_id] = { renderer: :label }
      fields[:style] = { renderer: :label }
      fields[:assembly_type] = { renderer: :label }
      fields[:market_major] = { renderer: :label }
      fields[:ctn_size_basic_pack] = { renderer: :label }
      fields[:ctn_size_old_pack] = { renderer: :label }
      fields[:pls_pack_code] = { renderer: :label }
      fields[:fruit_mass_nett_kg] = { renderer: :label }
      fields[:holes] = { renderer: :label }
      fields[:perforation] = { renderer: :label }
      fields[:image] = { renderer: :label }
      fields[:length_mm] = { renderer: :label }
      fields[:width_mm] = { renderer: :label }
      fields[:height_mm] = { renderer: :label }
      fields[:diameter_mm] = { renderer: :label }
      fields[:thick_mm] = { renderer: :label }
      fields[:thick_mic] = { renderer: :label }
      fields[:colour] = { renderer: :label }
      fields[:grade] = { renderer: :label }
      fields[:mass] = { renderer: :label }
      fields[:material_type] = { renderer: :label }
      fields[:treatment] = { renderer: :label }
      fields[:specification_notes] = { renderer: :label }
      fields[:artwork_commodity] = { renderer: :label }
      fields[:artwork_marketing_variety_group] = { renderer: :label }
      fields[:artwork_variety] = { renderer: :label }
      fields[:artwork_nett_mass] = { renderer: :label }
      fields[:artwork_brand] = { renderer: :label }
      fields[:artwork_class] = { renderer: :label }
      fields[:artwork_plu_number] = { renderer: :label }
      fields[:artwork_other] = { renderer: :label }
      fields[:artwork_image] = { renderer: :label }
      fields[:marketer] = { renderer: :label }
      fields[:retailer] = { renderer: :label }
      fields[:supplier] = { renderer: :label }
      fields[:supplier_stock_code] = { renderer: :label }
      fields[:product_alternative] = { renderer: :label }
      fields[:product_joint_use] = { renderer: :label }
      fields[:ownership] = { renderer: :label }
      fields[:consignment_stock] = { renderer: :label }
      fields[:start_date] = { renderer: :label }
      fields[:end_date] = { renderer: :label }
      fields[:remarks] = { renderer: :label }
    end

    def common_fields
      {
        material_resource_sub_type_id: { renderer: :select, options: @config_repo.for_select_matres_sub_types, caption: 'material_resource_sub_type' },
        product_number: {},
        description: {},
        commodity_id: { renderer: :select, options: @commodity_repo.for_select_commodities, disabled_options: @commodity_repo.for_select_inactive_commodities, caption: 'commodity' },
        variety_id: {},
        style: {},
        assembly_type: {},
        market_major: {},
        ctn_size_basic_pack: {},
        ctn_size_old_pack: {},
        pls_pack_code: {},
        fruit_mass_nett_kg: {},
        holes: {},
        perforation: {},
        image: {},
        length_mm: {},
        width_mm: {},
        height_mm: {},
        diameter_mm: {},
        thick_mm: {},
        thick_mic: {},
        colour: {},
        grade: {},
        mass: {},
        material_type: {},
        treatment: {},
        specification_notes: {},
        artwork_commodity: {},
        artwork_marketing_variety_group: {},
        artwork_variety: {},
        artwork_nett_mass: {},
        artwork_brand: {},
        artwork_class: {},
        artwork_plu_number: {},
        artwork_other: {},
        artwork_image: {},
        marketer: {},
        retailer: {},
        supplier: {},
        supplier_stock_code: {},
        product_alternative: {},
        product_joint_use: {},
        ownership: {},
        consignment_stock: { renderer: :checkbox },
        start_date: {},
        end_date: {},
        remarks: {}
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_pm_product(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(material_resource_sub_type_id: nil,
                                    product_number: nil,
                                    description: nil,
                                    commodity_id: nil,
                                    variety_id: nil,
                                    style: nil,
                                    assembly_type: nil,
                                    market_major: nil,
                                    ctn_size_basic_pack: nil,
                                    ctn_size_old_pack: nil,
                                    pls_pack_code: nil,
                                    fruit_mass_nett_kg: nil,
                                    holes: nil,
                                    perforation: nil,
                                    image: nil,
                                    length_mm: nil,
                                    width_mm: nil,
                                    height_mm: nil,
                                    diameter_mm: nil,
                                    thick_mm: nil,
                                    thick_mic: nil,
                                    colour: nil,
                                    grade: nil,
                                    mass: nil,
                                    material_type: nil,
                                    treatment: nil,
                                    specification_notes: nil,
                                    artwork_commodity: nil,
                                    artwork_marketing_variety_group: nil,
                                    artwork_variety: nil,
                                    artwork_nett_mass: nil,
                                    artwork_brand: nil,
                                    artwork_class: nil,
                                    artwork_plu_number: nil,
                                    artwork_other: nil,
                                    artwork_image: nil,
                                    marketer: nil,
                                    retailer: nil,
                                    supplier: nil,
                                    supplier_stock_code: nil,
                                    product_alternative: nil,
                                    product_joint_use: nil,
                                    ownership: nil,
                                    consignment_stock: nil,
                                    start_date: nil,
                                    end_date: nil,
                                    remarks: nil)
    end
  end
end
