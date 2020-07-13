# frozen_string_literal: true

module Development
  module Statuses
    module Status
      class Detail
        def self.call(id, remote: false) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:status, :detail, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.caption 'Status details'
              form.no_submit! unless remote
              form.row do |row|
                row.column do |col|
                  if rules[:rows].first[:status] == 'No current status' # time.nil?
                    col.add_notice 'No status detail', notice_type: :info
                  else
                    col.add_table(rules[:rows],
                                  rules[:cols],
                                  pivot: true,
                                  header_captions: rules[:header_captions],
                                  cell_transformers: { action_tstamp_tx: ->(a) { a&.strftime('%Y-%m-%d %H:%M:%S') } })
                  end
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
