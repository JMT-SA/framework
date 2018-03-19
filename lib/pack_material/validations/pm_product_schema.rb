# frozen_string_literal: true

module PackMaterialApp
  PmProductSchema = Dry::Validation.Form do
    optional(:id).filled(:int?)
    required(:material_resource_sub_type_id).filled(:int?)
    required(:product_number).filled(:int?)
    required(:description).maybe(:str?)
    optional(:commodity_id).filled(:int?)
    required(:variety_id).maybe(:str?)
    required(:style).maybe(:str?)
    required(:assembly_type).maybe(:str?)
    required(:market_major).maybe(:str?)
    required(:ctn_size_basic_pack).maybe(:str?)
    required(:ctn_size_old_pack).maybe(:str?)
    required(:pls_pack_code).maybe(:str?)
    required(:fruit_mass_nett_kg).maybe(:decimal?)
    required(:holes).maybe(:str?)
    required(:perforation).maybe(:str?)
    required(:image).maybe(:str?)
    required(:length_mm).maybe(:decimal?)
    required(:width_mm).maybe(:decimal?)
    required(:height_mm).maybe(:decimal?)
    required(:diameter_mm).maybe(:decimal?)
    required(:thick_mm).maybe(:decimal?)
    required(:thick_mic).maybe(:decimal?)
    required(:colour).maybe(:str?)
    required(:grade).maybe(:str?)
    required(:mass).maybe(:str?)
    required(:material_type).maybe(:str?)
    required(:treatment).maybe(:str?)
    required(:specification_notes).maybe(:str?)
    required(:artwork_commodity).maybe(:str?)
    required(:artwork_marketing_variety_group).maybe(:str?)
    required(:artwork_variety).maybe(:str?)
    required(:artwork_nett_mass).maybe(:str?)
    required(:artwork_brand).maybe(:str?)
    required(:artwork_class).maybe(:str?)
    required(:artwork_plu_number).maybe(:decimal?)
    required(:artwork_other).maybe(:str?)
    required(:artwork_image).maybe(:str?)
    required(:marketer).maybe(:str?)
    required(:retailer).maybe(:str?)
    required(:supplier).maybe(:str?)
    required(:supplier_stock_code).maybe(:str?)
    required(:product_alternative).maybe(:str?)
    required(:product_joint_use).maybe(:str?)
    required(:ownership).maybe(:str?)
    required(:consignment_stock).maybe(:bool?)
    required(:start_date).maybe(:date?)
    required(:end_date).maybe(:date?)
    required(:remarks).maybe(:str?)
  end
end