# frozen_string_literal: true

module Masterfiles
  module Fruit
    module Cultivar
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:cultivar, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :commodity_id
              form.add_field :cultivar_group_id
              form.add_field :cultivar_name
              form.add_field :description
            end
          end

          layout
        end
      end
    end
  end
end
