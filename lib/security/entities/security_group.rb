class SecurityGroup < Dry::Struct
  attribute :id, Types::Int
  attribute :security_group_name, Types::String
end
