# frozen_string_literal: true

module PackMaterialApp
  class MrDeliveryTerm < Dry::Struct
    attribute :id, Types::Integer
    attribute :delivery_term_code, Types::String
    attribute :description, Types::Bool
  end
end
