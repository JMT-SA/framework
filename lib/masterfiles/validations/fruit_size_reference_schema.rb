# frozen_string_literal: true

FruitSizeReferenceSchema = Dry::Validation.Form do
  configure { config.type_specs = true }

  optional(:id, :int).filled(:int?)
  required(:fruit_actual_counts_for_pack_id, :int).filled(:int?)
  required(:size_reference, Types::StrippedString).filled(:str?)
end
