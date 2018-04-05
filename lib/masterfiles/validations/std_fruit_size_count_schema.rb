# frozen_string_literal: true

StdFruitSizeCountSchema = Dry::Validation.Form do
  configure { config.type_specs = true }

  optional(:id, :int).filled(:int?)
  required(:commodity_id, :int).filled(:int?)
  required(:size_count_description, Types::StrippedString).maybe(:str?)
  required(:size_count_value, :int).filled(:int?)
  required(:size_count_interval_group, Types::StrippedString).maybe(:str?)
  required(:marketing_size_range_mm, Types::StrippedString).maybe(:str?)
  required(:marketing_weight_range, Types::StrippedString).maybe(:str?)
  required(:minimum_size_mm, :int).maybe(:int?)
  required(:maximum_size_mm, :int).maybe(:int?)
  required(:average_size_mm, :int).maybe(:int?)
  required(:minimum_weight_gm, :float).maybe(:float?)
  required(:maximum_weight_gm, :float).maybe(:float?)
  required(:average_weight_gm, :float).maybe(:float?)
end
