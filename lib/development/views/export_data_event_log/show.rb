# frozen_string_literal: true

module Development
  module Logging
    module ExportDataEventLog
      class Show
        def self.call(id) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:export_data_event_log, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              # form.caption 'Export Data Event Log'
              form.view_only!
              form.add_field :export_key
              form.add_text 'Event log', wrapper: :strong
              form.add_text ui_rule.form_object[:event_log], preformatted: true
              form.add_field :started_at
              form.add_field :completed_at
              form.add_field :complete
              form.add_field :failed
              form.add_field :error_message
            end
          end

          layout
        end
      end
    end
  end
end
