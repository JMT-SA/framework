# frozen_string_literal: true

module DevelopmentApp
  class DevelopmentRepo < BaseRepo
    IGNORE_TABLES = %i[schema_migrations users].freeze

    def table_list
      DB.tables.reject { |table| IGNORE_TABLES.include?(table) }.sort
    end

    def table_columns(table)
      DB.schema(table)
    end

    def table_col_names(table)
      # table_columns(table).map { |col, _| col }
      DB[table.to_sym].columns
    end

    def foreign_keys(table)
      DB.foreign_key_list(table)
    end

    def indexed_columns(table)
      DB.indexes(table).map do |_, index|
        index[:columns].length == 1 ? index[:columns].first : nil
      end.compact
    end

    # Array of columns that require unique values on their own
    def unique_columns(table)
      DB.indexes(table).select { |_, index| index[:unique] }.map { |_, index| index[:columns].length == 1 ? index[:columns].first : nil }.compact
    end
  end
end
