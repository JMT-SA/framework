# frozen_string_literal: true

module DevelopmentApp
  UserEmailGroupSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:mail_group).filled(Types::StrippedString)
  end
end
