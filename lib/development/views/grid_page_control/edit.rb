# frozen_string_literal: true

module Development
  module Grids
    module PageControl
      class Edit
        def self.call(form_values) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:grid_page_control, :edit, form_values: OpenStruct.new(form_values))
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            # page.form_values form_values
            # page.form_errors form_errors
            page.form do |form|
              form.action "/development/grids/grid_page_controls/#{form_values[:list_file]}/#{form_values[:index]}"
              form.remote!
              form.method :update
              form.add_field :list_file
              form.add_field :index
              form.add_field :text
              form.add_field :control_type
              form.add_field :url
              form.add_field :style
              form.add_field :behaviour
            end
          end

          layout
        end
      end
    end
  end
end
