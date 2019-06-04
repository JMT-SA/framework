# frozen_string_literal: true

module Masterfiles
  module Config
    module LabelTemplate
      class New
        def self.call(form_values: nil, form_errors: nil, remote: true)
          ui_rule = UiRules::Compiler.new(:label_template, :new, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action '/masterfiles/config/label_templates'
              form.remote! if remote
              form.add_field :label_template_name
              form.add_field :description
              form.add_field :application
              # form.add_field :variables
            end
          end

          layout
        end
      end
    end
  end
end
