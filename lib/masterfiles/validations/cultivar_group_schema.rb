# frozen_string_literal: true

module MasterfilesApp
  CultivarGroupSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:cultivar_group_code, Types::StrippedString).filled(:str?)
    required(:description, Types::StrippedString).maybe(:str?)
  end
end
