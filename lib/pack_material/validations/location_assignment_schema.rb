# frozen_string_literal: true

module PackMaterialApp
  LocationAssignmentSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:assignment_code, Types::StrippedString).filled(:str?)
  end
end
