# frozen_string_literal: true

BasicPackCodeSchema = Dry::Validation.Form do
  optional(:id).filled(:int?)
  required(:basic_pack_code).filled(:str?)
  required(:description).maybe(:str?)
  required(:length_mm).maybe(:int?)
  required(:width_mm).maybe(:int?)
  required(:height_mm).maybe(:int?)
end
