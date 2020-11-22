# frozen_string_literal: true

module MasterfilesApp
  LabelTemplateSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:label_template_name).filled(Types::StrippedString)
    required(:description).filled(Types::StrippedString)
    required(:application).filled(Types::StrippedString)
    optional(:variables).maybe(:array).each(:string)
  end
end
