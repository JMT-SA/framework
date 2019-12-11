# frozen_string_literal: true

module MasterfilesApp
  class AccountCode < Dry::Struct
    attribute :id, Types::Integer
    attribute :account_code, Types::Integer
    attribute :description, Types::String
  end
end
