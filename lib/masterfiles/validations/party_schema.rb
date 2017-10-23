# frozen_string_literal: true

PartySchema = Dry::Validation.Form do
  optional(:id).filled(:int?)
  required(:party_type).filled(:str?, max_size?: 1)
  required(:active).maybe(:bool?)
end
