# frozen_string_literal: true

module PackMaterialApp
  PmProductVariantSchema = Dry::Schema.Params do # rubocop:disable Metrics/BlockLength
    optional(:id).filled(:integer)
    optional(:pack_material_product_id).filled(:integer)
    optional(:product_variant_number).maybe(:integer)

    optional(:unit).maybe(Types::StrippedString)
    optional(:style).maybe(Types::StrippedString)
    optional(:alternate).maybe(Types::StrippedString)
    optional(:shape).maybe(Types::StrippedString)
    optional(:reference_size).maybe(Types::StrippedString)
    optional(:reference_dimension).maybe(Types::StrippedString)
    optional(:reference_dimension_2).maybe(Types::StrippedString)
    optional(:reference_quantity).maybe(Types::StrippedString)
    optional(:brand_1).maybe(Types::StrippedString)
    optional(:brand_2).maybe(Types::StrippedString)
    optional(:colour).maybe(Types::StrippedString)
    optional(:material).maybe(Types::StrippedString)
    optional(:assembly).maybe(Types::StrippedString)
    optional(:reference_mass).maybe(Types::StrippedString)
    optional(:reference_number).maybe(Types::StrippedString)
    optional(:market).maybe(Types::StrippedString)
    optional(:marking).maybe(Types::StrippedString)
    optional(:model).maybe(Types::StrippedString)
    optional(:pm_class).maybe(Types::StrippedString)
    optional(:grade).maybe(Types::StrippedString)
    optional(:language).maybe(Types::StrippedString)
    optional(:other).maybe(Types::StrippedString)
    optional(:analysis_code).maybe(Types::StrippedString)
    optional(:season_year_use).maybe(Types::StrippedString)
    optional(:party).maybe(Types::StrippedString)
    optional(:specification_reference).maybe(Types::StrippedString)
  end

  ClonePmProductVariantSchema = Dry::Schema.Params do # rubocop:disable Metrics/BlockLength
    required(:pack_material_product_id).filled(:integer)

    optional(:unit).maybe(Types::StrippedString)
    optional(:style).maybe(Types::StrippedString)
    optional(:alternate).maybe(Types::StrippedString)
    optional(:shape).maybe(Types::StrippedString)
    optional(:reference_size).maybe(Types::StrippedString)
    optional(:reference_dimension).maybe(Types::StrippedString)
    optional(:reference_dimension_2).maybe(Types::StrippedString)
    optional(:reference_quantity).maybe(Types::StrippedString)
    optional(:brand_1).maybe(Types::StrippedString)
    optional(:brand_2).maybe(Types::StrippedString)
    optional(:colour).maybe(Types::StrippedString)
    optional(:material).maybe(Types::StrippedString)
    optional(:assembly).maybe(Types::StrippedString)
    optional(:reference_mass).maybe(Types::StrippedString)
    optional(:reference_number).maybe(Types::StrippedString)
    optional(:market).maybe(Types::StrippedString)
    optional(:marking).maybe(Types::StrippedString)
    optional(:model).maybe(Types::StrippedString)
    optional(:pm_class).maybe(Types::StrippedString)
    optional(:grade).maybe(Types::StrippedString)
    optional(:language).maybe(Types::StrippedString)
    optional(:other).maybe(Types::StrippedString)
    optional(:analysis_code).maybe(Types::StrippedString)
    optional(:season_year_use).maybe(Types::StrippedString)
    optional(:party).maybe(Types::StrippedString)
    optional(:specification_reference).maybe(Types::StrippedString)
  end

  CompletedPmProductVariantSchema = Dry::Schema.Params do
    required(:product_variant_number).filled(:integer)
  end
end
