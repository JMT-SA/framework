# frozen_string_literal: true

module PackMaterialApp
  MrDeliveryItemSchema = Dry::Validation.Params do
    configure do
      config.type_specs = true

      def self.messages
        super.merge(en: { errors: { received_less_than_on_note: 'Quantity Received must be less than or equal to Quantity on Note.',
                                    remarks_if_quantity_difference: 'Remarks are required if there is a quantity difference',
                                    remarks_if_quantity_returned: 'Remarks are required if there is a quantity to be returned' } })
      end
    end

    optional(:id, :integer).filled(:int?)
    required(:mr_delivery_id, :integer).maybe(:int?)
    required(:mr_purchase_order_item_id, :integer).filled(:int?)
    required(:mr_product_variant_id, :integer).maybe(:int?)
    required(:quantity_on_note, :decimal).filled(:decimal?, gt?: 0)
    required(:quantity_received, :decimal).filled(:decimal?, gt?: 0)
    required(:quantity_returned, :decimal).filled(:decimal?, gteq?: 0)
    required(:quantity_difference, :decimal).filled(:decimal?, gteq?: 0)
    optional(:quantity_over_supplied, :decimal).maybe(:decimal?)
    optional(:quantity_under_supplied, :decimal).maybe(:decimal?)
    required(:invoiced_unit_price, :decimal).maybe(:decimal?)
    required(:remarks, Types::StrippedString).maybe(:str?)

    validate(received_less_than_on_note: %i[quantity_on_note quantity_received]) do |quantity_on_note, quantity_received|
      quantity_on_note >= quantity_received
    end
    validate(remarks_if_quantity_returned: %i[quantity_returned remarks]) do |returned, remarks|
      returned && returned&.positive? ? !remarks.nil? : true
    end
    validate(remarks_if_quantity_difference: %i[quantity_difference remarks]) do |diff, remarks|
      diff && diff&.positive? ? !remarks.nil? : true
    end
  end

  MrDeliveryItemQuantitySchema = Dry::Validation.Params do
    configure do
      config.type_specs = true

      def self.messages
        super.merge(en: { errors: { received_less_than_on_note: 'Quantity Received must be less than or equal to Quantity on Note.' } })
      end
    end

    required(:mr_delivery_item_mr_purchase_order_item_id, :integer).filled(:int?)
    required(:mr_delivery_item_quantity_on_note, :decimal).filled(:decimal?, gt?: 0)
    required(:mr_delivery_item_quantity_received, :decimal).filled(:decimal?, gt?: 0)
    required(:mr_delivery_item_quantity_returned, :decimal).filled(:decimal?, gteq?: 0)
    required(:mr_delivery_item_quantity_difference, :decimal).filled(:decimal?, gteq?: 0)

    validate(received_less_than_on_note: %i[mr_delivery_item_quantity_on_note mr_delivery_item_quantity_received]) do |quantity_on_note, quantity_received|
      # This validation is still required even if these fields are empty, but does not have to show as other validations will fail
      quantity_received && quantity_on_note ? quantity_on_note >= quantity_received : true
    end
  end
end
