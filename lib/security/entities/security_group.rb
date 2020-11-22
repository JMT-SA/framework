# frozen_string_literal: true

module SecurityApp
  class SecurityGroup < Dry::Struct
    attribute :id, Types::Integer
    attribute :security_group_name, Types::String
  end

  class SecurityGroupWithPermissions < Dry::Struct
    attribute :id, Types::Integer
    attribute :security_group_name, Types::String

    attribute :security_permissions, Types::Array.default([].freeze) do
      attribute :id, Types::Integer
      attribute :security_permission, Types::String
    end
  end
end
