# frozen_string_literal: true

module PackMaterialApp
  PmProductSchema = Dry::Schema.Params do # rubocop:disable Metrics/BlockLength
    optional(:material_resource_sub_type_id).filled(:integer)

    optional(:commodity_id).filled(:integer)
    optional(:marketing_variety_id).filled(:integer)

    optional(:unit).filled(Types::StrippedString)
    optional(:style).filled(Types::StrippedString)
    optional(:alternate).filled(Types::StrippedString)
    optional(:shape).filled(Types::StrippedString)
    optional(:reference_size).filled(Types::StrippedString)
    optional(:reference_dimension).filled(Types::StrippedString)
    optional(:reference_dimension_2).filled(Types::StrippedString)
    optional(:reference_quantity).filled(Types::StrippedString)
    optional(:brand_1).filled(Types::StrippedString)
    optional(:brand_2).filled(Types::StrippedString)
    optional(:colour).filled(Types::StrippedString)
    optional(:material).filled(Types::StrippedString)
    optional(:assembly).filled(Types::StrippedString)
    optional(:reference_mass).filled(Types::StrippedString)
    optional(:reference_number).filled(Types::StrippedString)
    optional(:market).filled(Types::StrippedString)
    optional(:marking).filled(Types::StrippedString)
    optional(:model).filled(Types::StrippedString)
    optional(:pm_class).filled(Types::StrippedString)
    optional(:grade).filled(Types::StrippedString)
    optional(:language).filled(Types::StrippedString)
    optional(:other).filled(Types::StrippedString)
    optional(:analysis_code).filled(Types::StrippedString)
    optional(:season_year_use).filled(Types::StrippedString)
    optional(:party).filled(Types::StrippedString)
  end

  ClonePmProductSchema = Dry::Schema.Params do # rubocop:disable Metrics/BlockLength
    required(:material_resource_sub_type_id).filled(:integer)

    optional(:commodity_id).filled(:integer)
    optional(:marketing_variety_id).filled(:integer)

    optional(:unit).filled(Types::StrippedString)
    optional(:style).filled(Types::StrippedString)
    optional(:alternate).filled(Types::StrippedString)
    optional(:shape).filled(Types::StrippedString)
    optional(:reference_size).filled(Types::StrippedString)
    optional(:reference_dimension).filled(Types::StrippedString)
    optional(:reference_dimension_2).filled(Types::StrippedString)
    optional(:reference_quantity).filled(Types::StrippedString)
    optional(:brand_1).filled(Types::StrippedString)
    optional(:brand_2).filled(Types::StrippedString)
    optional(:colour).filled(Types::StrippedString)
    optional(:material).filled(Types::StrippedString)
    optional(:assembly).filled(Types::StrippedString)
    optional(:reference_mass).filled(Types::StrippedString)
    optional(:reference_number).filled(Types::StrippedString)
    optional(:market).filled(Types::StrippedString)
    optional(:marking).filled(Types::StrippedString)
    optional(:model).filled(Types::StrippedString)
    optional(:pm_class).filled(Types::StrippedString)
    optional(:grade).filled(Types::StrippedString)
    optional(:language).filled(Types::StrippedString)
    optional(:other).filled(Types::StrippedString)
    optional(:analysis_code).filled(Types::StrippedString)
    optional(:season_year_use).filled(Types::StrippedString)
    optional(:party).filled(Types::StrippedString)
  end

  CompletedPmProductSchema = Dry::Schema.Params do
    required(:product_number).filled(:integer)
    required(:product_code).filled(Types::StrippedString)
  end
end
