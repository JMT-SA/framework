# frozen_string_literal: true

module SecurityApp
  ProgramFunctionCreateSchema = Dry::Schema.Params do
    required(:program_function_name).filled(Types::StrippedString)
    required(:url).filled(Types::StrippedString)
    required(:program_function_sequence).filled(:integer)
    required(:program_id).filled(:integer)
    required(:group_name).maybe(Types::StrippedString)
    required(:restricted_user_access).filled(:bool)
    required(:active).filled(:bool)
    optional(:show_in_iframe).filled(:bool)
  end
end
