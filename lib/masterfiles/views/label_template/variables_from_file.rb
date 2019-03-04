# frozen_string_literal: true

module Masterfiles
  module Config
    module LabelTemplate
      class VariablesFromFile
        def self.call(id, source, form_values: nil, form_errors: nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:label_template, :variables, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/masterfiles/config/label_templates/#{id}/get_variables/#{source}"
              form.remote!
              form.multipart!
              form.method :update
              form.add_field :label_template_name
              form.add_field :description
              form.add_field :variables
              form.submit_captions 'Get variables'
            end
          end

          layout
        end
      end
    end
  end
end
