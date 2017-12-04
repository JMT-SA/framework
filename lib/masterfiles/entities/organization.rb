class Organization < Dry::Struct
  attribute :id, Types::Int
  attribute :party_id, Types::Int
  attribute :party_name, Types::String
  attribute :parent_id, Types::Int
  attribute :short_description, Types::String
  attribute :medium_description, Types::String
  attribute :long_description, Types::String
  attribute :vat_number, Types::String
  attribute :variants, Types::String
  attribute :active, Types::Bool
  attribute :role_ids, Types::Array
  attribute :role_names, Types::Array
  attribute :parent_organization, Types::String
end
