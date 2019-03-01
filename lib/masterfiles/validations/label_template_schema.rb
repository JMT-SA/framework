# frozen_string_literal: true

module MasterfilesApp
  LabelTemplateSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:label_template_name, Types::StrippedString).filled(:str?)
    required(:description, Types::StrippedString).filled(:str?)
    required(:application, Types::StrippedString).filled(:str?)
    optional(:variables, :array).maybe(:array?) { each(:str?) }
  end
end
