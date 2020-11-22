# frozen_string_literal: true

module DM
  module Admin
    class HideGridColumns
      def self.call
        ui_rule = UiRules::Compiler.new(:hide_grid_columns, :select)
        rules   = ui_rule.compile

        layout = Crossbeams::Layout::Page.build(rules) do |page|
          page.form_object ui_rule.form_object
          page.form do |form|
            form.action '/dataminer/admin/hide_grid_columns'
            form.add_field :lists
            form.add_field :searches
            form.add_text('Choose either a list or a search.', wrapper: :p)
          end
        end

        layout
      end
    end
  end
end
