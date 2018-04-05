# frozen_string_literal: true

module SecurityApp
  EditProgramSchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    required(:program_name, Types::StrippedString).filled(:str?)
    required(:webapps, :array).filled(:array?)
  end
end
