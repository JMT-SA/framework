# frozen_string_literal: true

module DevelopmentApp
  # Take a table name and id and delete all audit trail items for that record.
  class ClearAuditTrail < BaseQueJob
    def run(table_name, id, options = {})
      raise Crossbeams::InfoError, 'ClearAuditTrail: Id must be an Integer' unless id.is_a?(Integer)

      repo = DevelopmentApp::LoggingRepo.new
      if options[:keep_latest]
        repo.clear_audit_trail_keeping_latest(table_name, id)
      else
        repo.clear_audit_trail(table_name, id)
      end
      finish
    end
  end
end
