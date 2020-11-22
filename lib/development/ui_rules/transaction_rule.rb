# frozen_string_literal: true

module UiRules
  class TransactionRule < Base
    def generate_rules # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      @repo = DevelopmentApp::LoggingRepo.new

      if @mode == :list
        rules[:transaction_sets] = []
        grp_recs = @repo.logged_actions_for_id(@options[:table_name], @options[:id]).group_by { |g| g[:transaction_id] }
        grp_recs.each do |transaction_id, tx_recs|
          rec1 = tx_recs.first
          st_recs = @repo.logged_transaction_statuses(transaction_id, rec1[:action_tstamp_tx])
          hs = {
            caption: "#{rec1[:action_tstamp_tx].strftime('%Y-%m-%d %H:%M:%S')} (#{transaction_id})",
            transactions: { rows: tx_recs.map { |t| { action: t[:action], changed_fields: t[:changed_fields] } }, cols: %i[action changed_fields] }
          }
          context = rec1[:context] ? " [#{rec1[:context]}]" : ''
          hs[:tx_detail] = "#{rec1[:request_ip]} - #{rec1[:route_url]}#{context} (#{rec1[:user_name] || 'User Not Logged'})" unless rec1[:route_url].nil?
          hs[:status] = st_recs.map { |s| "STATUS: #{s[:status]} #{s[:comment]} (#{s[:user_name] || 'User Not Logged'}, #{s[:table_name]}, id=#{s[:row_data_id]})" }.join('<br>') unless st_recs.empty?
          rules[:transaction_sets] << hs
        end
      end

      form_name 'logged_actions'
    end
  end
end
