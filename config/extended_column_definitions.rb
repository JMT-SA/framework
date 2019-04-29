# frozen_string_literal: true

module Crossbeams
  module Config
    # Store rules for JSONB contents of various tables per client.
    #
    # REQUIRED RULES
    # - type: :string, :boolean, :integer, :numeric
    # OPTIONAL RULES
    # - required: true/false (if true, the UI will prompt the user to fill in the field)
    # - default: any value
    # - masterlist_key: a list_type value from the master_lists table - used to populate a select box with options.
    class ExtendedColumnDefinitions
      EXTENDED_COLUMNS = {
      }.freeze

      VALIDATIONS = {
      }.freeze

      # Takes the configuration rules for an extended column
      # and unpacks it into +form.add_field+ calls which are applied to the
      # form parameter.
      #
      # @param table [symbol] the name of the table that has an extended_columns field.
      # @param form [Crossbeams::Form] the form/fold in which to place the fields.
      def self.extended_columns_for_view(table, form)
        config = EXTENDED_COLUMNS.dig(table, AppConst::CLIENT_CODE)
        return if config.nil?
        config.keys.each { |k| form.add_field("extcol_#{k}".to_sym) }
      end
    end
  end
end
