# frozen_string_literal: true

module PackMaterialApp
  MrDeliveryTermSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:delivery_term_code).maybe(Types::StrippedString)
    required(:description).maybe(Types::StrippedString)
  end
end
