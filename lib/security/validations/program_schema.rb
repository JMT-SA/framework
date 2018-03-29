# frozen_string_literal: true

module SecurityApp
  ProgramSchema = Dry::Validation.Schema do
    required(:program_name).filled(:str?)
  end
end
