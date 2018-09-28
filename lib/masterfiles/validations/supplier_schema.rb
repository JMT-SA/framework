# frozen_string_literal: true

module MasterfilesApp
  NewSupplierSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:party_id, :integer).filled(:int?)
    required(:supplier_type_ids, Types::IntArray).filled { each(:int?) }
    required(:erp_supplier_number, Types::StrippedString).maybe(:str?)
  end

  EditSupplierSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:supplier_type_ids, Types::IntArray).filled { each(:int?) }
    required(:erp_supplier_number, Types::StrippedString).maybe(:str?)
  end
end
