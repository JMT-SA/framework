# frozen_string_literal: true

FruitActualCountsForPackSchema = Dry::Validation.Form do
  optional(:id).filled(:int?)
  required(:std_fruit_size_count_id).filled(:int?)
  required(:basic_pack_code_id).filled(:int?)
  required(:standard_pack_code_id).filled(:int?)
  required(:actual_count_for_pack).filled(:int?)
  required(:size_count_variation).filled(:str?)
end
