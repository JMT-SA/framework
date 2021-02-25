# frozen_string_literal: true

# Document sequences are the definitions for a document number.
# e.g. purchase order number or invoice reference.
#
# Each document sequence needs a database sequence to be defined and
# config that defines how to present it.
#
# example:
#    purchase_order:
#      db_sequence_name: doc_seqs_po
#      data_type: :integer
#      table: purchase_orders
#      column: purchase_order_number
#    invoice_ref:
#      db_sequence_name: doc_seqs_inv
#      data_type: :string
#      prefix: INV
#      digit_length: 7
#      table: invoices
#      column: invoice_ref
#
# Reads a YAML config file to get the rules to apply for a document sequence.
# Public methods return SQL to be run by methods in a repository.
class DocumentSequence
  attr_reader :name

  # Read the configured rules from config/document_sequence.yml.
  #
  # @return [hash] the rules.
  def self.rules
    @rules ||= begin
                 path = File.join(ENV['ROOT'], 'config', 'document_sequence.yml')
                 YAML.load_file(path)
               end
  end

  # New DocumentSequence
  #
  # Validates the rules for the given name.
  #
  # @param name [string] the name of the document sequence.
  # @return [DocumentSequence]
  def initialize(name)
    @name = name.to_s
    raise ArgumentError, "Document sequence #{name} has no configuration" if rule.nil?

    assert_rule_ok!
  end

  # SQL that can be run to generate the next sequence for this document.
  #
  # @return [string] the SQL to be run.
  def next_sequence_sql
    "SELECT #{string_prefix}nextval('#{rule['db_sequence_name']}')#{string_suffix};"
  end

  # SQL that can be run to generate the next sequence for this document.
  # Returning the value in the "seq" column.
  #
  # @return [string] the SQL to be run.
  def next_sequence_sql_as_seq
    "SELECT #{string_prefix}nextval('#{rule['db_sequence_name']}')#{string_suffix} AS seq;"
  end

  # SQL to update a column in a table with the next sequence.
  #
  # @param id [integer] the id of the row to be updated,
  # @return [string] the SQL to be run.
  def next_sequence_update_sql(id)
    "UPDATE #{rule['table']} SET #{rule['column']} = (#{next_sequence_sql.delete_suffix(';')}) WHERE id = #{id};"
  end

  # String-representation of the DocumentSequence.
  #
  # @return [string] a simple text description.
  def to_s
    "#{name}: seq: '#{rule['db_sequence_name']}' for #{rule['table']}.#{rule['column']} (#{rule['data_type']})"
  end

  private

  def rule_schema
    Dry::Schema.define do
      required(:db_sequence_name).filled(:string)
      required(:data_type).value(type?: Symbol, included_in?: %i[integer string])
      optional(:prefix).maybe(:string)
      optional(:digit_length).filled(:integer)
      required(:table).filled(:string)
      required(:column).filled(:string)
    end
  end

  def assert_rule_ok!
    res_errs = rule_schema.call(rule.transform_keys(&:to_sym)).errors(full: true).to_h
    return if res_errs.empty?

    raise ArgumentError, "Document sequence config for #{name} is not valid: #{res_errs.map { |_, v| v.join(', ') }.join(', ')}"
  end

  def string_prefix
    return '' unless rule['data_type'] == :string

    ar = []
    ar << "concat('#{rule['prefix']}', " if rule['prefix']
    ar << 'to_char('
    ar.join
  end

  def string_suffix
    return '' unless rule['data_type'] == :string

    ar = []
    ar << ", 'FM#{string_format}')"
    ar << ')' if rule['prefix']
    ar.join
  end

  # Use the postgresql format string for to_char.
  # If there is no digit rule or the digit length is zero or less, use a large set of nines
  # so that whatever is passed in will come back as a string of numbers without leading zeroes
  # and without truncating the number.
  def string_format
    return '999999999999999999999999999' if rule['digit_length'].nil? || rule['digit_length'] < 1

    "#{'0' * (rule['digit_length'] - 1)}9"
  end

  def rule
    @rule ||= begin
                DocumentSequence.rules[name]
              end
  end
end
