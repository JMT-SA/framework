# frozen_string_literal: true

module PackMaterialApp
  MrDeliveryItemBatchSchema = Dry::Validation.Params do
    configure do
      config.type_specs = true

      def self.messages
        super.merge(en: { errors: { internal_or_client_batch_number: 'must provide either client or internal batch number' } })
      end
    end

    optional(:id, :integer).filled(:int?)
    required(:mr_delivery_item_id, :integer).filled(:int?)
    required(:mr_internal_batch_number_id, :integer).maybe(:int?)
    required(:client_batch_number, Types::StrippedString).maybe(:str?)
    required(:quantity_on_note, :decimal).maybe(:decimal?)
    required(:quantity_received, :decimal).maybe(:decimal?)

    validate(internal_or_client_batch_number: %i[mr_internal_batch_number_id client_batch_number]) do |mr_internal_batch_number_id, client_batch_number|
      mr_internal_batch_number_id || client_batch_number
    end
  end
end
