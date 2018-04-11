# frozen_string_literal: true

module MasterfilesApp
  PartySchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    optional(:id, :int).filled(:int?)
    required(:party_type, Types::StrippedString).filled(:str?, max_size?: 1)
    required(:active, :bool).maybe(:bool?)
  end
end
