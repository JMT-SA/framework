# frozen_string_literal: true

StandardPackCodeSchema = Dry::Validation.Form do
  configure { config.type_specs = true }

  optional(:id, :int).filled(:int?)
  required(:standard_pack_code, Types::StrippedString).filled(:str?)
end
