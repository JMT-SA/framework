# frozen_string_literal: true

module MasterfilesApp
  CultivarSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:commodity_id, :integer).filled(:int?)
    required(:cultivar_group_id, :integer).maybe(:int?)
    required(:cultivar_name, Types::StrippedString).filled(:str?)
    required(:description, Types::StrippedString).maybe(:str?)
  end
end
