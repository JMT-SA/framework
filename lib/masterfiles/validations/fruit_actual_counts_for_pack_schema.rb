# frozen_string_literal: true

module MasterfilesApp
  FruitActualCountsForPackSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:std_fruit_size_count_id).filled(:integer)
    required(:actual_count_for_pack).filled(:integer)
    required(:size_count_variation).filled(Types::StrippedString)

    required(:basic_pack_code_id).filled(:integer)
    required(:standard_pack_code_id).filled(:integer)
  end
end
