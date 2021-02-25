# frozen_string_literal: true

module PackMaterialApp
  class MatresProductVariantContract < Dry::Validation::Contract
    params do
      optional(:id).filled(:integer)
      required(:product_variant_id).filled(:integer)
      required(:product_variant_table_name).filled(:string)
      optional(:product_variant_number).filled(:integer)
      required(:old_product_code).maybe(:string)
      required(:supplier_lead_time).maybe(:integer)
      required(:minimum_stock_level).maybe(:decimal)
      required(:re_order_stock_level).maybe(:decimal)
      required(:use_fixed_batch_number).maybe(:bool)
      required(:mr_internal_batch_number_id).maybe(:integer)
    end

    rule(:use_fixed_batch_number, :mr_internal_batch_number_id) do
      base.failure('must provide batch number if use_fixed_batch_number is set') if values[:use_fixed_batch_number] == true && values[:mr_internal_batch_number_id].nil?
    end
  end
  # MatresProductVariantSchema = Dry::Schema.Params do
  #   configure do
  #     config.type_specs = true
  #
  #     def self.messages
  #       super.merge(en: { errors: { base_batch_number_required: 'must provide batch number if use_fixed_batch_number is set' } })
  #     end
  #   end
  #
  #   optional(:id, :integer).filled(:int?)
  #   required(:product_variant_id, :integer).filled(:int?)
  #   required(:product_variant_table_name, Types::StrippedString).filled(:str?)
  #   optional(:product_variant_number, :integer).filled(:int?)
  #   required(:old_product_code, Types::StrippedString).maybe(:str?)
  #   required(:supplier_lead_time, :integer).maybe(:int?)
  #   required(:minimum_stock_level, :decimal).maybe(:decimal?)
  #   required(:re_order_stock_level, :decimal).maybe(:decimal?)
  #   required(:use_fixed_batch_number, :bool).maybe(:bool?)
  #   required(:mr_internal_batch_number_id, :integer).maybe(:int?)
  #
  #   validate(base_batch_number_required: %i[use_fixed_batch_number mr_internal_batch_number_id]) do |use_fixed, batch_number_id|
  #     if use_fixed == true
  #       !batch_number_id.nil?
  #     else
  #       true
  #     end
  #   end
  # end
end
