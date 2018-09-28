# frozen_string_literal: true

module MasterfilesApp
  class StandardPackCode < Dry::Struct
    attribute :id, Types::Integer
    attribute :standard_pack_code, Types::String
  end
end
