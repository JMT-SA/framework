# frozen_string_literal: true

module MasterfilesApp
  StdFruitSizeCountSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:commodity_id).filled(:integer)
    required(:size_count_description).maybe(Types::StrippedString)
    required(:size_count_value).filled(:integer)
    required(:size_count_interval_group).maybe(Types::StrippedString)
    required(:marketing_size_range_mm).maybe(Types::StrippedString)
    required(:marketing_weight_range).maybe(Types::StrippedString)
    required(:minimum_size_mm).maybe(:integer)
    required(:maximum_size_mm).maybe(:integer)
    required(:average_size_mm).maybe(:integer)
    required(:minimum_weight_gm).maybe(:float)
    required(:maximum_weight_gm).maybe(:float)
    required(:average_weight_gm).maybe(:float)
  end
end
