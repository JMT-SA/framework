# frozen_string_literal: true

module DevelopmentApp
  class StatusRepo < BaseRepo
    crud_calls_for :current_statuses, name: :status, wrapper: Status, schema: :audit, exclude: %i[create update delete]
    crud_calls_for :status_logs, name: :status_log, wrapper: Status, schema: :audit, exclude: %i[create update delete]

    def find_by_table_and_id(table_name, id)
      res = where_hash(Sequel[:audit][:current_statuses], table_name: table_name.to_s, row_data_id: id)
      return nil if res.nil?

      Status.new(res)
    end

    def find_status_log_with_details(id) # rubocop:disable Metrics/AbcSize
      res = DB[Sequel[:audit][:status_logs]]
            .left_outer_join(Sequel[:audit][:logged_action_details], transaction_id: :transaction_id)
            .where(Sequel[:status_logs][:id] => id)
            .select(Sequel[:status_logs][:id],
                    Sequel[:status_logs][:transaction_id],
                    Sequel[:status_logs][:action_tstamp_tx],
                    Sequel[:status_logs][:table_name],
                    Sequel[:status_logs][:row_data_id],
                    Sequel[:status_logs][:comment],
                    Sequel[:status_logs][:user_name],
                    Sequel[:logged_action_details][:context],
                    Sequel[:logged_action_details][:route_url],
                    Sequel[:logged_action_details][:request_ip],
                    Sequel.function(:concat_ws, ' ', :status, :comment).as('status'))
            .first
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
        status[:request_ip] = log_det[:request_ip]
        status[:context] = log_det[:context]
      end
      status
    end

    def list_statuses(table_name, id)
      DB[Sequel[:audit][:status_logs]]
        .where(table_name: table_name.to_s, row_data_id: id)
        .select(:id,
                :transaction_id,
                Sequel.function(:date_trunc, 'second', :action_tstamp_tx).as('action_time'),
                Sequel.function(:concat_ws, ' ', :status, :comment).as('status'),
                :user_name)
        .order(:action_tstamp_tx)
        .all
    end
  end
end
