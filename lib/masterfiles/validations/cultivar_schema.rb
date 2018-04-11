# frozen_string_literal: true

module MasterfilesApp
  CultivarSchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    optional(:id, :int).filled(:int?)
    required(:commodity_id, :int).filled(:int?)
    required(:cultivar_group_id, :int).maybe(:int?)
    required(:cultivar_name, Types::StrippedString).filled(:str?)
    required(:description, Types::StrippedString).maybe(:str?)
  end
end
