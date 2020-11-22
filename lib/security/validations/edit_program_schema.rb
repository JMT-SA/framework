# frozen_string_literal: true

module SecurityApp
  EditProgramSchema = Dry::Schema.Params do
    required(:program_name).filled(Types::StrippedString)
    required(:program_sequence).filled(:integer, gt?: 0)
    required(:webapps).filled(:array).each(:string)
  end
end
