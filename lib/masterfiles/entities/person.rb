# frozen_string_literal: true

class Person < Dry::Struct
  attribute :id, Types::Int
  attribute :party_id, Types::Int
  attribute :surname, Types::String
  attribute :first_name, Types::String
  attribute :title, Types::String
  attribute :vat_number, Types::String
  attribute :active, Types::Bool
  # attribute :role_ids, Types::Array #TODO remove if unused
end
__END__
SELECT p.*, array_agg(SELECT id FROM party_roles WHERE party_id = p.party_id) AS role_ids
FROM people p
WHERE id = ...


# frozen_string_literal: true

class Person
  # We need a class here that contains independent business logic
  class Entity < Dry::Struct
    attribute :id, Types::Int
    attribute :party_id, Types::Int
    attribute :surname, Types::String
    attribute :first_name, Types::String
    attribute :title, Types::String
    attribute :vat_number, Types::String
    attribute :active, Types::Bool
    # attribute :role_ids, Types::Array #TODO remove if unused
  end

  def name

  end

  # Problem here is person needs to be able to delegate to Entity Dry Struct
  # Have a look at Sequel Model
  # Have a look at simple delegator

  def initialize(hash)
    entity = Entity.new(hash)
  end

end
__END__
SELECT p.*, array_agg(SELECT id FROM party_roles WHERE party_id = p.party_id) AS role_ids
FROM people p
WHERE id = ...
