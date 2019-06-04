# frozen_string_literal: true

module Development
  module Statuses
    module Status
      class List
        def self.call(table_name, id, remote: false) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:status, :list, table_name: table_name, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.caption "Status for #{table_name}" unless remote
              form.no_submit! unless remote
              form.row do |row|
                row.column do |col|
                  if rules[:detail_rows] && !rules[:detail_rows].empty? # rubocop:disable Style/IfUnlessModifier
                    col.add_table(rules[:detail_rows], rules[:detail_cols], header_captions: rules[:detail_headers], caption: rules[:detail_caption], top_margin: 2)
                  end
                  col.add_table(rules[:rows], rules[:cols], header_captions: rules[:header_captions], top_margin: 3)

                  col.add_notice 'No status changes have been logged yet', notice_type: :info if rules[:rows].empty?
                end
              end
            end
          end

          layout
        end
      end
    end
  end
end
