# frozen_string_literal: true

module LabelApp
  MesModuleSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:module_code, Types::StrippedString).filled(:str?)
    required(:module_type, Types::StrippedString).filled(:str?)
    required(:server_ip, Types::StrippedString).filled(:str?)
    required(:ip_address, Types::StrippedString).filled(:str?)
    required(:port, :integer).filled(:int?)
    required(:alias, Types::StrippedString).filled(:str?)
  end
end
