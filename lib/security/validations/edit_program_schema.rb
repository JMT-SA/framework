# frozen_string_literal: true

module SecurityApp
  EditProgramSchema = Dry::Validation.Form do
    required(:program_name).filled(:str?)
    required(:webapps).filled(:array?)
  end
end
