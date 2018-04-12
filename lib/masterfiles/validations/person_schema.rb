# frozen_string_literal: true

module MasterfilesApp
  PersonSchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    optional(:id, :int).filled(:int?)
    required(:surname, Types::StrippedString).filled(:str?)
    required(:first_name, Types::StrippedString).filled(:str?)
    required(:title, Types::StrippedString).filled(:str?)
    required(:vat_number, Types::StrippedString).maybe(:str?)
    required(:role_ids, :array).filled { each(:int?) }
    required(:active, :bool).maybe(:bool?)
  end
end
