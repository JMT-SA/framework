# frozen_string_literal: true

module Masterfiles
  module Fruit
    module FruitSizeReference
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:fruit_size_reference, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :fruit_actual_counts_for_pack_id
              form.add_field :size_reference
            end
          end

          layout
        end
      end
    end
  end
end
