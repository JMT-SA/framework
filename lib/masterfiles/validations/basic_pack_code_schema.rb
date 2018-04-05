# frozen_string_literal: true

BasicPackCodeSchema = Dry::Validation.Form do
  configure { config.type_specs = true }

  optional(:id, :int).filled(:int?)
  required(:basic_pack_code, Types::StrippedString).filled(:str?)
  required(:description, Types::StrippedString).maybe(:str?)
  required(:length_mm, :int).maybe(:int?)
  required(:width_mm, :int).maybe(:int?)
  required(:height_mm, :int).maybe(:int?)
end
