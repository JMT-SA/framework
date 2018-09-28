# frozen_string_literal: true

module SecurityApp
  EditProgramSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    required(:program_name, Types::StrippedString).filled(:str?)
    required(:program_sequence, :integer).filled(:int?, gt?: 0)
    required(:webapps, :array).filled(:array?)
  end
end
