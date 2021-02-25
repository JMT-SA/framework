# frozen_string_literal: true

module MasterfilesApp
  CultivarGroupSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:cultivar_group_code).filled(Types::StrippedString)
    required(:description).maybe(Types::StrippedString)
  end
end
