# frozen_string_literal: true

module DevelopmentApp
  ScriptScaffoldNewSchema = Dry::Schema.Params do
    required(:script_class).filled(Types::StrippedString)
    required(:description).filled(Types::StrippedString)
    required(:reason).filled(Types::StrippedString)
  end
end
