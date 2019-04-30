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

      def verify_config
        if EXTENDED_COLUMNS.empty?
          puts 'Nothing to verify'
          return
        end
        errs = verify_client_keys

        EXTENDED_COLUMNS.each do |table, rules|
          rules.each do |client_code, rule|
            errs += verify_validation(table, client_code, rule)
          end
        end
        if errs.empty?
          puts 'ExtendedColumnDefinitions is OK'
        else
          puts "ExtendedColumnDefinitions ERROR: #{errs.join(', ')}"
        end
      end

      def verify_client_keys
        errs = []
        EXTENDED_COLUMNS.each { |_, v| v.keys.each { |key| errs << "Client code key must be a string: #{key.inspect}" unless key.is_a?(String) } }
        errs
      end

      def verify_validation(table, client_code, rule)
        errs = []
        val = VALIDATIONS[table][client_code]
        if val.nil?
          errs << "#{table.inspect}/#{client_code} does not have a validation rule."
        else
          diff = rule.keys - val.rules.keys
          errs << "#{table.inspect}/#{client_code} validation does not cover all columns (#{diff.join(', ')})" unless diff.empty?
        end
        errs
      end
    end
  end
end
