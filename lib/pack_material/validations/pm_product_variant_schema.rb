# frozen_string_literal: true

module PackMaterialApp
  PmProductVariantSchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    optional(:id, :int).filled(:int?)
    optional(:pack_material_product_id, :int).filled(:int?)
    optional(:product_variant_number, Types::StrippedString).maybe(:str?)

    optional(:unit, Types::StrippedString).maybe(:str?)
    optional(:style, Types::StrippedString).maybe(:str?)
    optional(:alternate, Types::StrippedString).maybe(:str?)
    optional(:shape, Types::StrippedString).maybe(:str?)
    optional(:reference_size, Types::StrippedString).maybe(:str?)
    optional(:reference_quantity, Types::StrippedString).maybe(:str?)
    optional(:length_mm, :decimal).maybe(:decimal?)
    optional(:width_mm, :decimal).maybe(:decimal?)
    optional(:height_mm, :decimal).maybe(:decimal?)
    optional(:diameter_mm, :decimal).maybe(:decimal?)
    optional(:thick_mm, :decimal).maybe(:decimal?)
    optional(:thick_mic, :decimal).maybe(:decimal?)
    optional(:brand_1, Types::StrippedString).maybe(:str?)
    optional(:brand_2, Types::StrippedString).maybe(:str?)
    optional(:colour, Types::StrippedString).maybe(:str?)
    optional(:material, Types::StrippedString).maybe(:str?)
    optional(:assembly, Types::StrippedString).maybe(:str?)
    optional(:reference_mass, Types::StrippedString).maybe(:str?)
    optional(:reference_number, Types::StrippedString).maybe(:str?)
    optional(:market, Types::StrippedString).maybe(:str?)
    optional(:marking, Types::StrippedString).maybe(:str?)
    optional(:model, Types::StrippedString).maybe(:str?)
    optional(:pm_class, Types::StrippedString).maybe(:str?)
    optional(:grade, Types::StrippedString).maybe(:str?)
    optional(:language, Types::StrippedString).maybe(:str?)
    optional(:other, Types::StrippedString).maybe(:str?)
  end

  ClonePmProductVariantSchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    required(:pack_material_product_id, :int).filled(:int?)

    optional(:unit, Types::StrippedString).maybe(:str?)
    optional(:style, Types::StrippedString).maybe(:str?)
    optional(:alternate, Types::StrippedString).maybe(:str?)
    optional(:shape, Types::StrippedString).maybe(:str?)
    optional(:reference_size, Types::StrippedString).maybe(:str?)
    optional(:reference_quantity, Types::StrippedString).maybe(:str?)
    optional(:length_mm, :decimal).maybe(:decimal?)
    optional(:width_mm, :decimal).maybe(:decimal?)
    optional(:height_mm, :decimal).maybe(:decimal?)
    optional(:diameter_mm, :decimal).maybe(:decimal?)
    optional(:thick_mm, :decimal).maybe(:decimal?)
    optional(:thick_mic, :decimal).maybe(:decimal?)
    optional(:brand_1, Types::StrippedString).maybe(:str?)
    optional(:brand_2, Types::StrippedString).maybe(:str?)
    optional(:colour, Types::StrippedString).maybe(:str?)
    optional(:material, Types::StrippedString).maybe(:str?)
    optional(:assembly, Types::StrippedString).maybe(:str?)
    optional(:reference_mass, Types::StrippedString).maybe(:str?)
    optional(:reference_number, Types::StrippedString).maybe(:str?)
    optional(:market, Types::StrippedString).maybe(:str?)
    optional(:marking, Types::StrippedString).maybe(:str?)
    optional(:model, Types::StrippedString).maybe(:str?)
    optional(:pm_class, Types::StrippedString).maybe(:str?)
    optional(:grade, Types::StrippedString).maybe(:str?)
    optional(:language, Types::StrippedString).maybe(:str?)
    optional(:other, Types::StrippedString).maybe(:str?)
  end

  CompletedPmProductVariantSchema = Dry::Validation.Form do
    required(:product_variant_number, Types::StrippedString).filled(:str?)
  end
end
