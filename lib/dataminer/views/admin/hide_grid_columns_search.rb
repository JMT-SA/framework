# frozen_string_literal: true

module DM
  module Admin
    class HideGridColumnsSearch
      def self.call(file)
        ui_rule = UiRules::Compiler.new(:hide_grid_columns, :search, file: file)
        rules   = ui_rule.compile

        layout = Crossbeams::Layout::Page.build(rules) do |page|
          page.add_text("#{rules[:type]}: #{rules[:caption]}", wrapper: :h2, css_classes: 'mb0')
          page.add_text("Toggle the checkbox in a client column to hide the column when the \"#{rules[:caption]}\" search grid is displayed for that client.", wrapper: :p)
          page.section do |section|
            section.fit_height!
            section.add_grid('search_hide_grid', "/dataminer/admin/hide_grid_columns/searches_grid/#{file}", caption: rules[:caption])
          end
        end

        layout
      end
    end
  end
end
