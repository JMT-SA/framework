# frozen_string_literal: true

module Development
  module Logging
    module LoggedAction
      class TransactionSql
        def self.call(id, sql)
          layout = Crossbeams::Layout::Page.build({}) do |page|
            page.add_text "Event id #{id}", wrapper: :strong
            page.add_text sql.map { |s| UtilityFunctions.wrapped_sql(s) }.join("\n\n---\n\n"), syntax: :sql
          end

          layout
        end
      end
    end
  end
end
