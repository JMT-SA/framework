# frozen_string_literal: true

module MasterfilesApp
  TmGroupSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:target_market_group_type_id, :integer).filled(:int?)
    required(:target_market_group_name, Types::StrippedString).filled(:str?)
  end
end
