# frozen_string_literal: true

module MasterfilesApp
  NewCustomerSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:party_id, :integer).filled(:int?)
    required(:customer_type_ids, Types::IntArray).filled { each(:int?) }
    required(:erp_customer_number, Types::StrippedString).maybe(:str?)
  end

  EditCustomerSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:customer_type_ids, Types::IntArray).filled { each(:int?) }
    required(:erp_customer_number, Types::StrippedString).maybe(:str?)
  end
end
