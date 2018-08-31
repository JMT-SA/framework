# frozen_string_literal: true

module PackMaterialApp
  LocationAssignmentSchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    optional(:id, :int).filled(:int?)
    required(:assignment_code, Types::StrippedString).filled(:str?)
  end
end
