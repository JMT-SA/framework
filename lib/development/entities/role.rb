class Role < Dry::Struct
  attribute :id, Types::Int
  attribute :name, Types::String
  attribute :active, Types::Bool
end