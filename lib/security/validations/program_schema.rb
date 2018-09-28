# frozen_string_literal: true

module SecurityApp
  ProgramSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    required(:program_name, Types::StrippedString).filled(:str?)
    required(:program_sequence, :integer).filled(:int?, gt?: 0)
    optional(:functional_area_id, :integer).maybe(:int?)
  end
end
