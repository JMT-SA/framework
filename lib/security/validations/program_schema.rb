# frozen_string_literal: true

module SecurityApp
  ProgramSchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    required(:program_name, Types::StrippedString).filled(:str?)
    required(:program_sequence, :int).filled(:int?, gt?: 0)
    optional(:functional_area_id, :int).maybe(:int?)
  end
end
