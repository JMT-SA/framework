# frozen_string_literal: true

module PackMaterialApp
  MatresProductVariantSchema = Dry::Validation.Params do
    configure do
      config.type_specs = true

      def self.messages
        super.merge(en: { errors: { base_batch_number_required: 'must provide batch number if use_fixed_batch_number is set' } })
      end
    end

    optional(:id, :integer).filled(:int?)
    required(:product_variant_id, :integer).filled(:int?)
    required(:product_variant_table_name, Types::StrippedString).filled(:str?)
    optional(:product_variant_number, :integer).filled(:int?)
    required(:old_product_code, Types::StrippedString).maybe(:str?)
    required(:supplier_lead_time, :integer).maybe(:int?)
    required(:minimum_stock_level, :integer).maybe(:int?)
    required(:re_order_stock_level, :integer).maybe(:int?)
    required(:use_fixed_batch_number, :bool).maybe(:bool?)
    required(:mr_internal_batch_number_id, :integer).maybe(:int?)

    validate(base_batch_number_required: %i[use_fixed_batch_number mr_internal_batch_number_id]) do |use_fixed, batch_number_id|
      if use_fixed == true
        !batch_number_id.nil?
      else
        true
      end
    end
  end
end
