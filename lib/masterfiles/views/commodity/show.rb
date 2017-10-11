# frozen_string_literal: true

module Masterfiles
  module Fruit
    module Commodity
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:commodity, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :commodity_group_id
              form.add_field :code
              form.add_field :description
              form.add_field :hs_code
              form.add_field :active
            end
          end

          layout
        end
      end
    end
  end
end
