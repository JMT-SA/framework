# frozen_string_literal: true

class PartyRole < Dry::Struct
  attribute :id, Types::Int
  attribute :party_id, Types::Int
  attribute :role_id, Types::Int
  attribute :organization_id, Types::Int
  attribute :person_id, Types::Int
  attribute :active, Types::Bool

  def is_organization?
    @person_id.nil?
  end
end
