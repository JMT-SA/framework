# frozen_string_literal: true

module MasterfilesApp
  class CustomerType < Dry::Struct
    attribute :id, Types::Integer
    attribute :type_code, Types::String
  end
end
