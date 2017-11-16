# frozen_string_literal: true

StdFruitSizeCountSchema = Dry::Validation.Form do
  optional(:id).filled(:int?)
  required(:commodity_id).filled(:int?)
  required(:size_count_description).maybe(:str?)
  required(:size_count_value).filled(:int?)
  required(:size_count_interval_group).maybe(:str?)
  required(:marketing_size_range_mm).maybe(:str?)
  required(:marketing_weight_range).maybe(:str?)
  required(:minimum_size_mm).maybe(:int?)
  required(:maximum_size_mm).maybe(:int?)
  required(:average_size_mm).maybe(:int?)
  required(:minimum_weight_gm).maybe(:float?)
  required(:maximum_weight_gm).maybe(:float?)
  required(:average_weight_gm).maybe(:float?)
end
