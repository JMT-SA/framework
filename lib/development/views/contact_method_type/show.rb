# frozen_string_literal: true

module Development
  module Masterfiles
    module ContactMethodType
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:contact_method_type, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :contact_method_code
            end
          end

          layout
        end
      end
    end
  end
end