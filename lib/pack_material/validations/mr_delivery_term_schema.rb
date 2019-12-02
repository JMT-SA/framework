# frozen_string_literal: true

module PackMaterialApp
  MrDeliveryTermSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:delivery_term_code, Types::StrippedString).maybe(:str?)
    required(:description, Types::StrippedString).maybe(:str?)
  end
end
