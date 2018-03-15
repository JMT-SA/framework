# frozen_string_literal: true

module UiRules
  class PackMaterialProductRule < Base
    def generate_rules
      @this_repo = PackMaterialProductRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'pack_material_product'
    end

    def set_show_fields
      # product_type_id_label = PackMaterialProductRepo.new.find_product_type(@form_object.product_type_id)&.id
      material_resource_sub_type_id_label = @this_repo.find(:material_resource_sub_types, MaterialResourceSubType, @form_object.material_resource_sub_type_id)&.id
      # commodity_id_label = .find(:material_resource_sub_types, MaterialResourceSubType, @form_object.material_resource_sub_type_id)&.id
      fields[:material_resource_sub_type_id] = { renderer: :label, with_value: material_resource_sub_type_id_label, caption: 'product_type' }
      fields[:product_type_name] = { renderer: :label }
      fields[:variant] = { renderer: :label }
      fields[:style] = { renderer: :label }
      fields[:assembly_type] = { renderer: :label }
      fields[:market_major] = { renderer: :label }
      fields[:commodity_id] = { renderer: :label }
      fields[:variety] = { renderer: :label }
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
        product_type_id: { renderer: :select, options: PackMaterialProductRepo.new.for_select_product_types, caption: 'Product Type' },
        product_type_name: {},
        variant: {},
        active: { renderer: :checkbox },
        style: {},
        assembly_type: {},
        market_major: {},
        commodity_id: { renderer: :select, options: CommodityRepo.new.for_select_commodities, caption: 'Commodity' }, #Lookup
        variety: {}, #Lookup
        ctn_size_basic_pack: {}, #Lookup
        ctn_size_old_pack: {}, #Lookup
        pls_pack_code: {}, #Lookup
        fruit_mass_nett_kg: { renderer: :numeric },
        holes: {},
        perforation: {},
        image: {}, #Image Uploader
        length_mm: { renderer: :numeric },
        width_mm: { renderer: :numeric },
        height_mm: { renderer: :numeric },
        diameter_mm: { renderer: :numeric },
        thick_mm: { renderer: :numeric },
        thick_mic: { renderer: :numeric },
        colour: {},
        grade: {},
        mass: {},
        material_type: {},
        treatment: {},
        specification_notes: { renderer: :text },
        artwork_commodity: {},
        artwork_marketing_variety_group: {},
        artwork_variety: {},
        artwork_nett_mass: {},
        artwork_brand: {},
        artwork_class: {},
        artwork_plu_number: { renderer: :numeric },
        artwork_other: {},
        artwork_image: {},
        marketer: {}, #Lookup
        retailer: {}, #Lookup
        supplier: {}, #Lookup #AlwaysActive
        supplier_stock_code: {}, #AlwaysActive
        product_alternative: {}, #Validate if the product code given here is a valid entry
        product_joint_use: {}, #Validate if the product code given here is a valid entry
        ownership: {},
        consignment_stock: { renderer: :checkbox },
        start_date: { renderer: :date }, #AlwaysActive
        end_date: { renderer: :date }, #AlwaysActive
        remarks: { renderer: :text } #AlwaysActive
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @this_repo.find_product(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(product_type_id: nil,
                                    product_type_name: nil,
                                    variant: nil,
                                    style: nil,
                                    assembly_type: nil,
                                    market_major: nil,
                                    commodity_id: nil,
                                    variety: nil,
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
