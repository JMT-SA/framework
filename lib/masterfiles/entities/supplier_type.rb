# frozen_string_literal: true

module MasterfilesApp
  class SupplierType < Dry::Struct
    attribute :id, Types::Int
    attribute :type_code, Types::String
  end
end
