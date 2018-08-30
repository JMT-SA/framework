# frozen_string_literal: true

module MasterfilesApp
  class CustomerType < Dry::Struct
    attribute :id, Types::Int
    attribute :type_code, Types::String
  end
end
