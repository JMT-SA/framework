# frozen_string_literal: true

StandardPackCodeSchema = Dry::Validation.Form do
  optional(:id).filled(:int?)
  required(:standard_pack_code).filled(:str?)
end
