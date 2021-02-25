# frozen_string_literal: true

module DevelopmentApp
  RoleSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:name).filled(Types::StrippedString)
  end
end
