# frozen_string_literal: true

module MasterfilesApp
  FruitSizeReferenceSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:size_reference).filled(Types::StrippedString)
    required(:fruit_actual_counts_for_pack_id).filled(:integer)
  end
end
