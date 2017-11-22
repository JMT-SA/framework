# frozen_string_literal: true

FruitSizeReferenceSchema = Dry::Validation.Form do
  optional(:id).filled(:int?)
  required(:fruit_actual_counts_for_pack_id).filled(:int?)
  required(:size_reference).filled(:str?)
end
