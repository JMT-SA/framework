# frozen_string_literal: true

module MasterfilesApp
  class StandardPackCode < Dry::Struct
    attribute :id, Types::Int
    attribute :standard_pack_code, Types::String
  end
end
