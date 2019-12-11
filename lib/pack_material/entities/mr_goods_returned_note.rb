# frozen_string_literal: true

module PackMaterialApp
  class MrGoodsReturnedNote < Dry::Struct
    attribute :id, Types::Integer
    attribute :mr_delivery_id, Types::Integer
    attribute :issue_transaction_id, Types::Integer
    attribute :dispatch_location_id, Types::Integer
    attribute :created_by, Types::String
    attribute :remarks, Types::String
    attribute :delivery_number, Types::Integer
    attribute :credit_note_number, Types::Integer
    attribute :status, Types::String
    attribute :shipped, Types::Bool
    attribute :invoice_completed, Types::Bool
  end
end
