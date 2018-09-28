# frozen_string_literal: true

module SecurityApp
  FunctionalAreaSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    required(:functional_area_name, Types::StrippedString).filled(:str?)
  end
end
