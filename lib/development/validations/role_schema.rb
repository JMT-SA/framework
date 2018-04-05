# frozen_string_literal: true

RoleSchema = Dry::Validation.Form do
  configure { config.type_specs = true }

  optional(:id, :int).filled(:int?)
  required(:name, Types::StrippedString).maybe(:str?)
  required(:active, :bool).maybe(:bool?)
end
