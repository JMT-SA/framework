# frozen_string_literal: true

module Masterfiles
  module Fruit
    module StandardPackCode
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:standard_pack_code, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :standard_pack_code
            end
          end

          layout
        end
      end
    end
  end
end
