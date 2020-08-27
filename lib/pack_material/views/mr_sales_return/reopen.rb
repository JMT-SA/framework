# frozen_string_literal: true

module PackMaterial
  module Dispatch
    module MrSalesReturn
      class Reopen
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:mr_sales_return, :reopen, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.caption 'Reopen Sales Return'
              form.action "/pack_material/dispatch/mr_sales_returns/#{id}/reopen"
              form.remote!
              form.submit_captions 'Reopen'
              form.add_text 'Are you sure you want to reopen this mr_sales_return for editing?', wrapper: :h3
              form.add_field :mr_sales_order_id
              form.add_field :issue_transaction_id
              form.add_field :created_by
              form.add_field :remarks
              form.add_field :sales_return_number
            end
          end

          layout
        end
      end
    end
  end
end
