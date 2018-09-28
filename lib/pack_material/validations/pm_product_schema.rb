# frozen_string_literal: true

module PackMaterialApp
  PmProductSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:material_resource_sub_type_id, :integer).filled(:int?)

    optional(:commodity_id, :integer).filled(:int?)
    optional(:marketing_variety_id, :integer).filled(:int?)

    optional(:unit, Types::StrippedString).filled(:str?)
    optional(:style, Types::StrippedString).filled(:str?)
    optional(:alternate, Types::StrippedString).filled(:str?)
    optional(:shape, Types::StrippedString).filled(:str?)
    optional(:reference_size, Types::StrippedString).filled(:str?)
    optional(:reference_dimension, Types::StrippedString).filled(:str?)
    optional(:reference_quantity, Types::StrippedString).filled(:str?)
    optional(:brand_1, Types::StrippedString).filled(:str?)
    optional(:brand_2, Types::StrippedString).filled(:str?)
    optional(:colour, Types::StrippedString).filled(:str?)
    optional(:material, Types::StrippedString).filled(:str?)
    optional(:assembly, Types::StrippedString).filled(:str?)
    optional(:reference_mass, Types::StrippedString).filled(:str?)
    optional(:reference_number, Types::StrippedString).filled(:str?)
    optional(:market, Types::StrippedString).filled(:str?)
    optional(:marking, Types::StrippedString).filled(:str?)
    optional(:model, Types::StrippedString).filled(:str?)
    optional(:pm_class, Types::StrippedString).filled(:str?)
    optional(:grade, Types::StrippedString).filled(:str?)
    optional(:language, Types::StrippedString).filled(:str?)
    optional(:other, Types::StrippedString).filled(:str?)
  end

  ClonePmProductSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    required(:material_resource_sub_type_id, :integer).filled(:int?)

    optional(:commodity_id, :integer).filled(:int?)
    optional(:marketing_variety_id, :integer).filled(:int?)

    optional(:unit, Types::StrippedString).filled(:str?)
    optional(:style, Types::StrippedString).filled(:str?)
    optional(:alternate, Types::StrippedString).filled(:str?)
    optional(:shape, Types::StrippedString).filled(:str?)
    optional(:reference_size, Types::StrippedString).filled(:str?)
    optional(:reference_dimension, Types::StrippedString).filled(:str?)
    optional(:reference_quantity, Types::StrippedString).filled(:str?)
    optional(:brand_1, Types::StrippedString).filled(:str?)
    optional(:brand_2, Types::StrippedString).filled(:str?)
    optional(:colour, Types::StrippedString).filled(:str?)
    optional(:material, Types::StrippedString).filled(:str?)
    optional(:assembly, Types::StrippedString).filled(:str?)
    optional(:reference_mass, Types::StrippedString).filled(:str?)
    optional(:reference_number, Types::StrippedString).filled(:str?)
    optional(:market, Types::StrippedString).filled(:str?)
    optional(:marking, Types::StrippedString).filled(:str?)
    optional(:model, Types::StrippedString).filled(:str?)
    optional(:pm_class, Types::StrippedString).filled(:str?)
    optional(:grade, Types::StrippedString).filled(:str?)
    optional(:language, Types::StrippedString).filled(:str?)
    optional(:other, Types::StrippedString).filled(:str?)
  end

  CompletedPmProductSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    required(:product_number, :integer).filled(:int?)
    required(:product_code, Types::StrippedString).filled(:str?)
  end
end
