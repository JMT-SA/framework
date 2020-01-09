# frozen_string_literal: true

module LabelApp
  class MesModule < Dry::Struct
    attribute :id, Types::Integer
    attribute :module_code, Types::String
    attribute :module_type, Types::String
    attribute :server_ip, Types::String
    attribute :ip_address, Types::String
    attribute :port, Types::Integer
    attribute :alias, Types::String
    attribute? :active, Types::Bool
  end
end
