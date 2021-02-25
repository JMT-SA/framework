# frozen_string_literal: true

module MasterfilesApp
  NewSupplierSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:party_id).filled(:integer)
    required(:supplier_type_ids).filled(:array).each(:integer)
    required(:erp_supplier_number).maybe(Types::StrippedString)
  end

  EditSupplierSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:supplier_type_ids).filled(:array).each(:integer)
    required(:erp_supplier_number).maybe(Types::StrippedString)
  end
end
