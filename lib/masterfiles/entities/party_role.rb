# frozen_string_literal: true

module MasterfilesApp
  class PartyRole < Dry::Struct
    attribute :id, Types::Integer
    attribute :party_id, Types::Integer
    attribute :party_name, Types::String
    attribute :role_id, Types::Integer
    attribute :organization_id, Types::Integer
    attribute :person_id, Types::Integer
    attribute :active, Types::Bool

    def organization?
      @person_id.nil?
    end
  end
end
