# frozen_string_literal: true

module Masterfiles
  module Config
    module LabelTemplate
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:label_template, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :label_template_name
              form.add_field :description
              form.add_field :application
              form.add_field :active
              form.add_list ui_rule.form_object.variables, caption: 'Variable list'
            end
          end

          layout
        end
      end
    end
  end
end
