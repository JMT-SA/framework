# frozen_string_literal: true

module PackMaterial
  module Replenish
    module MrDeliveryItemBatch
      class PrintBarcode
        # @param [String] type 'item_batch' || 'internal_batch'
        def self.call(id, form_values: nil, form_errors: nil, type: nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:mr_delivery_item_batch, :print_barcode, id: id, type: type, form_values: form_values)
          rules   = ui_rule.compile

          url_params = "mr_delivery_item_batch_id=#{rules[:mr_delivery_item_batch_id]}" if type == 'item_batch'
          url_params = "mr_delivery_item_id=#{rules[:delivery_item_id]}" if type == 'internal_batch'

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/pack_material/replenish/print_sku_barcode?#{url_params}"
              form.remote!
              form.method :update
              form.add_field :sku_number
              form.add_field :product_variant_code
              form.add_field :batch_number
              form.add_field :printer
              form.add_field :no_of_prints
            end
          end

          layout
        end
      end
    end
  end
end
