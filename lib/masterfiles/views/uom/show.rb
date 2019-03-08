# frozen_string_literal: true

module Masterfiles
  module General
    module Uom
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:uom, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              # form.caption 'Uom'
              form.view_only!
              form.add_field :uom_type_id
              form.add_field :uom_code
            end
          end

          layout
        end
      end
    end
  end
end
