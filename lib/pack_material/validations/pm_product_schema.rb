# frozen_string_literal: true

module PackMaterialApp
  PmProductSchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    optional(:id, :int).filled(:int?)
    required(:material_resource_sub_type_id, :int).filled(:int?)
    required(:commodity_id, :int).maybe(:int?)
    required(:variety_id, :int).maybe(:int?)
    required(:product_number, :int).maybe(:int?)
    required(:product_code, Types::StrippedString).maybe(:str?)
    required(:unit, Types::StrippedString).maybe(:str?)
    required(:style, Types::StrippedString).maybe(:str?)
    required(:alternate, Types::StrippedString).maybe(:str?)
    required(:shape, Types::StrippedString).maybe(:str?)
    required(:reference_size, Types::StrippedString).maybe(:str?)
    required(:reference_quantity, Types::StrippedString).maybe(:str?)
    required(:length_mm, :decimal).maybe(:decimal?)
    required(:width_mm, :decimal).maybe(:decimal?)
    required(:height_mm, :decimal).maybe(:decimal?)
    required(:diameter_mm, :decimal).maybe(:decimal?)
    required(:thick_mm, :decimal).maybe(:decimal?)
    required(:thick_mic, :decimal).maybe(:decimal?)
    required(:brand_1, Types::StrippedString).maybe(:str?)
    required(:brand_2, Types::StrippedString).maybe(:str?)
    required(:colour, Types::StrippedString).maybe(:str?)
    required(:material, Types::StrippedString).maybe(:str?)
    required(:assembly, Types::StrippedString).maybe(:str?)
    required(:reference_mass, Types::StrippedString).maybe(:str?)
    required(:reference_number, Types::StrippedString).maybe(:str?)
    required(:market, Types::StrippedString).maybe(:str?)
    required(:marking, Types::StrippedString).maybe(:str?)
    required(:model, Types::StrippedString).maybe(:str?)
    required(:pm_class, Types::StrippedString).maybe(:str?)
    required(:grade, Types::StrippedString).maybe(:str?)
    required(:language, Types::StrippedString).maybe(:str?)
    required(:other, Types::StrippedString).maybe(:str?)
    required(:specification_notes, Types::StrippedString).maybe(:str?)
  end
end
