# frozen_string_literal: true

module MasterfilesApp
  StandardPackCodeSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:standard_pack_code, Types::StrippedString).filled(:str?)
  end
end
