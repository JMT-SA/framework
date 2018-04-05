# frozen_string_literal: true

CultivarGroupSchema = Dry::Validation.Form do
  configure { config.type_specs = true }

  optional(:id, :int).filled(:int?)
  required(:cultivar_group_code, Types::StrippedString).filled(:str?)
  required(:description, Types::StrippedString).maybe(:str?)
end
