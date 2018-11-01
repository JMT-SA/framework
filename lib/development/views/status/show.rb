# frozen_string_literal: true

module Development
  module Statuses
    module Status
      class Show
        def self.call(table_name, id, remote: false) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:status, :show, table_name: table_name, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page| # rubocop:disable Metrics/BlockLength
            page.form_object ui_rule.form_object
            page.form do |form| # rubocop:disable Metrics/BlockLength
              form.view_only!
              form.no_submit! unless remote
              form.row do |row| # rubocop:disable Metrics/BlockLength
                row.column do |col|
                  col.add_field :status
                  col.add_field :user_name
                  col.add_field :route_url
                  col.add_field :action_tstamp_tx
                  col.add_field :table_name
                  col.add_field :row_data_id
                  col.add_field :context
                  unless ui_rule.form_object[:diff_id].nil?
                    col.add_control(control_type: :link,
                                    text: 'View changes',
                                    url: "/development/logging/logged_actions/#{ui_rule.form_object[:diff_id]}/diff",
                                    behaviour: :popup,
                                    style: :button)
                  end
                  col.add_text '<h3>Status history</h3>'
                  col.add_table(rules[:details], rules[:headers], header_captions: rules[:header_captions])
                  col.add_text '<h3>Other status changes</h3>'
                  if remote
                    col.add_table((rules[:other_details] || []).map do |a|
                      a[:link] = a[:link].sub('<a', '<a data-replace-dialog="y" ')
                      a
                    end, rules[:other_headers], header_captions: rules[:other_header_captions])
                  else
                    col.add_table(rules[:other_details], rules[:other_headers], header_captions: rules[:other_header_captions])
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
