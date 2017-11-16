# frozen_string_literal: true

module Masterfiles
  module Fruit
    module BasicPackCode
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:basic_pack_code, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :basic_pack_code
              form.add_field :description
              form.add_field :length_mm
              form.add_field :width_mm
              form.add_field :height_mm
            end
          end

          layout
        end
      end
    end
  end
end
