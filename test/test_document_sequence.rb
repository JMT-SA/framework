# frozen_string_literal: true

require File.join(File.expand_path('./../', __FILE__), 'test_helper')

class TestDocumentSequence < MiniTest::Test
  def integer_rule
    {"db_sequence_name"=>"doc_seqs_po", "data_type"=>:integer, "table"=>"purchase_orders", "column"=>"purchase_order_number"}
  end

  def string_rule
    {"db_sequence_name"=>"doc_seqs_inv", "data_type"=>:string, "prefix"=>"INV", "digit_length"=>7, "table"=>"invoices", "column"=>"invoice_ref"}
  end

  def test_init
    DocumentSequence.any_instance.stubs(:rule).returns(integer_rule)
    ds = DocumentSequence.new('purchase_order')
    assert_equal "purchase_order: seq: 'doc_seqs_po' for purchase_orders.purchase_order_number (integer)", ds.to_s

    DocumentSequence.any_instance.stubs(:rule).returns(nil)
    assert_raises(ArgumentError) { DocumentSequence.new('non_existent') }
  end

  def test_rule_validation
    DocumentSequence.any_instance.stubs(:rule).returns(integer_rule)
    ds = DocumentSequence.new('purchase_order')
    refute_nil ds.next_sequence_sql

    DocumentSequence.any_instance.stubs(:rule).returns(string_rule)
    ds = DocumentSequence.new('purchase_order')
    refute_nil ds.next_sequence_sql

    ns = integer_rule.dup
    ns.delete('db_sequence_name')
    DocumentSequence.any_instance.stubs(:rule).returns(ns)
    assert_raises(ArgumentError) { DocumentSequence.new('invoice') }

    ns = integer_rule.dup
    ns.delete('data_type')
    DocumentSequence.any_instance.stubs(:rule).returns(ns)
    assert_raises(ArgumentError) { DocumentSequence.new('invoice') }

    ns = integer_rule.dup
    ns.delete('table')
    DocumentSequence.any_instance.stubs(:rule).returns(ns)
    assert_raises(ArgumentError) { DocumentSequence.new('invoice') }

    ns = integer_rule.dup
    ns.delete('column')
    DocumentSequence.any_instance.stubs(:rule).returns(ns)
    assert_raises(ArgumentError) { DocumentSequence.new('invoice') }

    ns = integer_rule.dup
    ns['data_type'] = 'integer'
    DocumentSequence.any_instance.stubs(:rule).returns(ns)
    assert_raises(ArgumentError) { DocumentSequence.new('invoice') }

    ns = integer_rule.dup
    ns['data_type'] = :boolean
    DocumentSequence.any_instance.stubs(:rule).returns(ns)
    assert_raises(ArgumentError) { DocumentSequence.new('invoice') }

    ns = integer_rule.dup
    ns['digit_length'] = '99'
    DocumentSequence.any_instance.stubs(:rule).returns(ns)
    assert_raises(ArgumentError) { DocumentSequence.new('invoice') }
  end

  def test_next_seq_sql
    DocumentSequence.any_instance.stubs(:rule).returns(integer_rule)
    ds = DocumentSequence.new('purchase_order')
    assert_equal "SELECT nextval('doc_seqs_po');", ds.next_sequence_sql

    DocumentSequence.any_instance.stubs(:rule).returns(string_rule)
    ds = DocumentSequence.new('invoice')
    assert_equal "SELECT concat('INV', to_char(nextval('doc_seqs_inv'), 'FM0000009'));", ds.next_sequence_sql

    ns = string_rule.dup
    ns.delete('prefix')
    ns.delete('digit_length')
    DocumentSequence.any_instance.stubs(:rule).returns(ns)
    ds = DocumentSequence.new('invoice')
    assert_equal "SELECT to_char(nextval('doc_seqs_inv'), 'FM999999999999999999999999999');", ds.next_sequence_sql

    ns = string_rule.dup
    ns.delete('prefix')
    ns['digit_length'] = 1
    DocumentSequence.any_instance.stubs(:rule).returns(ns)
    ds = DocumentSequence.new('invoice')
    assert_equal "SELECT to_char(nextval('doc_seqs_inv'), 'FM9');", ds.next_sequence_sql

    ns = string_rule.dup
    ns.delete('prefix')
    ns['digit_length'] = 3
    DocumentSequence.any_instance.stubs(:rule).returns(ns)
    ds = DocumentSequence.new('invoice')
    assert_equal "SELECT to_char(nextval('doc_seqs_inv'), 'FM009');", ds.next_sequence_sql

    ns = string_rule.dup
    ns['prefix'] = 'SOMEWEIRDTHING'
    ns['digit_length'] = 3
    DocumentSequence.any_instance.stubs(:rule).returns(ns)
    ds = DocumentSequence.new('invoice')
    assert_equal "SELECT concat('SOMEWEIRDTHING', to_char(nextval('doc_seqs_inv'), 'FM009'));", ds.next_sequence_sql
  end

  def test_next_seq_upd_sql
    DocumentSequence.any_instance.stubs(:rule).returns(integer_rule)
    ds = DocumentSequence.new('purchase_order')
    assert_equal "UPDATE purchase_orders SET purchase_order_number = (SELECT nextval('doc_seqs_po')) WHERE id = 12;", ds.next_sequence_update_sql(12)

    DocumentSequence.any_instance.stubs(:rule).returns(string_rule)
    ds = DocumentSequence.new('invoice')
    assert_equal "UPDATE invoices SET invoice_ref = (SELECT concat('INV', to_char(nextval('doc_seqs_inv'), 'FM0000009'))) WHERE id = 12;", ds.next_sequence_update_sql(12)
  end
end
