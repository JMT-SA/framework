# frozen_string_literal: true

module MasterfilesApp
  NewSupplierSchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    optional(:id, :int).filled(:int?)
    required(:party_id, :int).filled(:int?)
    required(:supplier_type_id, :int).filled(:int?)
    required(:erp_supplier_number, Types::StrippedString).maybe(:str?)
  end

  EditSupplierSchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    optional(:id, :int).filled(:int?)
    required(:supplier_type_id, :int).filled(:int?)
    required(:erp_supplier_number, Types::StrippedString).maybe(:str?)
  end
end
