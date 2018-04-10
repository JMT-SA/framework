# frozen_string_literal: true

module Development
  module Logging
    module LoggedAction
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:logged_action, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              # TODO: CB layout to handle get action...
              # form.action '/list/logged_actions'
              # form.method :get
              form.view_only!
              form.no_submit!
              form.add_field :schema_name
              form.add_field :table_name
              form.add_field :row_data_id
            end
            page.add_grid('logged_actions', "/development/logging/logged_actions/#{id}/grid", caption: 'Column details')
          end

          layout
        end
      end
    end
  end
end
