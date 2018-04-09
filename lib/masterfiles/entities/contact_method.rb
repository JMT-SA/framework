# frozen_string_literal: true

module MasterfilesApp
  class ContactMethod < Dry::Struct
    attribute :id, Types::Int
    attribute :contact_method_type_id, Types::Int
    attribute :contact_method_code, Types::String
    attribute :active, Types::Bool
    attribute :contact_method_type, Types::String
  end
end
