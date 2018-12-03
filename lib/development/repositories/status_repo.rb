# frozen_string_literal: true

module DevelopmentApp
  class StatusRepo < BaseRepo
    crud_calls_for :current_statuses, name: :status, wrapper: Status, schema: :audit, exclude: %i[create update delete]

    def find_by_table_and_id(table_name, id)
      res = where_hash(Sequel[:audit][:current_statuses], table_name: table_name.to_s, row_data_id: id)
      return nil if res.nil?
      Status.new(res)
    end

    def find_with_logs(table_name, id) # rubocop:disable Metrics/AbcSize
      status = DB[Sequel[:audit][:current_statuses]]
               .where(table_name: table_name.to_s, row_data_id: id)
               .select(Sequel.lit('*'), Sequel.function(:concat_ws, ' ', :status, :comment).as('status'))
               .first
      return { status: 'No current status' } if status.nil?

      status[:other_recs] = DB[Sequel[:audit][:current_statuses]]
                            .select(Sequel.lit('*'), Sequel.function(:concat_ws, ' ', :status, :comment).as('status'))
                            .where(transaction_id: status[:transaction_id]).all
                            .reject { |r| r[:id] == status[:id] }
                            .map { |r| r.merge(link: "<a href='/development/statuses/show/#{r[:table_name]}/#{r[:row_data_id]}'>view</a>") }

      status[:logs] = DB[Sequel[:audit][:status_logs]]
                      .where(table_name: table_name.to_s, row_data_id: id)
                      .select(Sequel.lit('*'), Sequel.function(:concat_ws, ' ', :status, :comment).as('status')).all
      log = DB[Sequel[:audit][:logged_actions]].where(transaction_id: status[:transaction_id],
                                                      table_name: table_name.to_s,
                                                      row_data_id: id).select(:event_id).first
      log_det = DB[Sequel[:audit][:logged_action_details]].where(transaction_id: status[:transaction_id]).first
      status[:diff_id] = log[:event_id] if log
      if log_det
        status[:route_url] = log_det[:route_url]
        status[:context] = log_det[:context]
      end
      status
    end
  end
end
