# frozen_string_literal: true

module PackMaterial
  module Dispatch
    module MrSalesReturn
      class New
        def self.call(form_values: nil, form_errors: nil, remote: true)
          ui_rule = UiRules::Compiler.new(:mr_sales_return, :new, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.caption 'New Sales Return'
              form.action '/pack_material/dispatch/mr_sales_returns'
              form.remote! if remote
              form.add_field :mr_sales_order_id
            end
          end

          layout
        end
      end
    end
  end
end
