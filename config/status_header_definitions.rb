# frozen_string_literal: true

module Crossbeams
  module Config
    # Store rules for displaying header information for a record from a table.
    #
    # The Hash key is the table name as a Symbol.
    # query: is the query to run with a '?' placehoder for the id value.
    # headers: is a hash of column_name to String values for overriding the column name.
    # caption: is an optional caption for the record.
    class StatusHeaderDefinitions
      HEADER_DEF = {
        mr_deliveries: {
          query: 'SELECT delivery_number, client_delivery_ref_number, supplier_invoice_ref_number FROM mr_deliveries WHERE id = ?',
          headers: { delivery_ref_number: 'Ref no', supplier_invoice_ref_number: 'Supplier Ref' },
          caption: 'Delivery'
        },
        security_groups: {
          query: 'SELECT security_group_name FROM security_groups WHERE id = ?'
        }
      }.freeze
    end
  end
end
