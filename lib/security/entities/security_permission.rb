# frozen_string_literal: true

module SecurityApp
  class SecurityPermission < Dry::Struct
    attribute :id, Types::Integer
    attribute :security_permission, Types::String
  end
end
