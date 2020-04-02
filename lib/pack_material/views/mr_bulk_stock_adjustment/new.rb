# frozen_string_literal: true

module PackMaterial
  module Transactions
    module MrBulkStockAdjustment
      class New
        def self.call(bsa_type, form_values: nil, form_errors: nil, remote: true) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:mr_bulk_stock_adjustment, :new, form_values: form_values, bsa_type: bsa_type)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.caption rules[:caption]
              form.action "/pack_material/transactions/mr_bulk_stock_adjustments?bsa_type=#{bsa_type}"
              form.remote! if remote
              form.add_field :business_process_id
              form.add_field :ref_no
              form.add_field :carton_assembly
              form.add_field :staging_consumption
            end
          end

          layout
        end
      end
    end
  end
end
