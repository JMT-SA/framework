# frozen_string_literal: true

module DevelopmentApp
  class LoggingRepo < BaseRepo
    crud_calls_for :logged_action_details, name: :logged_action_detail, wrapper: LoggedActionDetail

    def find_logged_action_hash(id)
      where_hash(Sequel[:audit][:logged_actions], event_id: id)
    end

    def find_logged_action(id)
      hash = find_logged_action_hash(id)
      return nil if hash.nil?
      LoggedAction.new(hash)
    end

    def logged_actions_for_id(table_name, id)
      query = <<~SQL
        SELECT a.event_id, a.action_tstamp_tx,
         CASE a.action WHEN 'I' THEN 'INS' WHEN 'U' THEN 'UPD'
          WHEN 'D' THEN 'DEL' ELSE 'TRUNC' END AS action,
         l.user_name, l.context, l.route_url,
         a.statement_only, a.row_data, a.changed_fields,
         ROW_NUMBER() OVER() + 1 AS id
        FROM audit.logged_actions a
        LEFT OUTER JOIN audit.logged_action_details l ON l.transaction_id = a.transaction_id AND l.action_tstamp_tx = a.action_tstamp_tx
        WHERE a.table_name = '#{table_name}'
          AND a.row_data_id = #{id}
        ORDER BY a.action_tstamp_tx DESC
      SQL
      DB[query].all
    end
  end
end
