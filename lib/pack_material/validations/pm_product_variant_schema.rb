# frozen_string_literal: true

module PackMaterialApp
  PmProductVariantSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    optional(:pack_material_product_id, :integer).filled(:int?)
    optional(:product_variant_number, :integer).maybe(:int?)

    optional(:unit, Types::StrippedString).maybe(:str?)
    optional(:style, Types::StrippedString).maybe(:str?)
    optional(:alternate, Types::StrippedString).maybe(:str?)
    optional(:shape, Types::StrippedString).maybe(:str?)
    optional(:reference_size, Types::StrippedString).maybe(:str?)
    optional(:reference_dimension, Types::StrippedString).maybe(:str?)
    optional(:reference_quantity, Types::StrippedString).maybe(:str?)
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

  ClonePmProductVariantSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    required(:pack_material_product_id, :integer).filled(:int?)

    optional(:unit, Types::StrippedString).maybe(:str?)
    optional(:style, Types::StrippedString).maybe(:str?)
    optional(:alternate, Types::StrippedString).maybe(:str?)
    optional(:shape, Types::StrippedString).maybe(:str?)
    optional(:reference_size, Types::StrippedString).maybe(:str?)
    optional(:reference_dimension, Types::StrippedString).maybe(:str?)
    optional(:reference_quantity, Types::StrippedString).maybe(:str?)
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

  CompletedPmProductVariantSchema = Dry::Validation.Params do
    required(:product_variant_number, :integer).filled(:int?)
  end
end
