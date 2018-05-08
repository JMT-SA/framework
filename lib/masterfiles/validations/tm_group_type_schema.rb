# frozen_string_literal: true

module MasterfilesApp
  TmGroupTypeSchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    optional(:id, :int).filled(:int?)
    required(:target_market_group_type_code, Types::StrippedString).filled(:str?)
  end
end