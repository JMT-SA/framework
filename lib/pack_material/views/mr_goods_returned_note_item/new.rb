# frozen_string_literal: true

module PackMaterial
  module Dispatch
    module MrGoodsReturnedNoteItem
      class New
        def self.call(parent_id, form_values: nil, form_errors: nil, remote: true)
          ui_rule = UiRules::Compiler.new(:mr_goods_returned_note_item, :new, form_values: form_values, parent_id: parent_id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.add_notice 'No more items or batches available for this delivery', notice_type: :info if rules[:zero_options]
            page.form do |form|
              form.caption 'New Goods Returned Note Item'
              form.action "/pack_material/dispatch/mr_goods_returned_notes/#{parent_id}/mr_goods_returned_note_items"
              form.remote! if remote
              form.add_field :delivery_item
            end
          end

          layout
        end
      end
    end
  end
end
