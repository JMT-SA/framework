# frozen_string_literal: true

module LabelApp
  MesModuleSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:module_code).filled(Types::StrippedString)
    required(:module_type).filled(Types::StrippedString)
    required(:server_ip).filled(Types::StrippedString)
    required(:ip_address).filled(Types::StrippedString)
    required(:port).filled(:integer)
    required(:alias).filled(Types::StrippedString)
  end
end
