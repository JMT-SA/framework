# frozen_string_literal: true

module DM
  module Admin
    class New
      def self.call(for_grid_queries: false, form_values: nil, form_errors: nil)
        ui_rule = UiRules::Compiler.new(:report, :new, form_values: form_values, for_grids: for_grid_queries)
        rules   = ui_rule.compile
        heading = if for_grid_queries
                    'New grid definition query'
                  else
                    'New report'
                  end

        layout = Crossbeams::Layout::Page.build(rules) do |page|
          page.form_object ui_rule.form_object
          page.form_values form_values
          page.form_errors form_errors
          page.add_text(heading, wrapper: :h2)
          page.form do |form|
            form.action '/dataminer/admin/create/'
            form.add_field :database
            form.add_field :filename
            form.add_field :caption
            form.add_field :sql
          end
        end

        layout
      end
    end
  end
end
