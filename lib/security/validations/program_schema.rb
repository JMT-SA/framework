# frozen_string_literal: true

module SecurityApp
  ProgramSchema = Dry::Schema.Params do
    required(:program_name).filled(Types::StrippedString)
    required(:program_sequence).filled(:integer, gt?: 0)
    optional(:functional_area_id).maybe(:integer)
  end
end
