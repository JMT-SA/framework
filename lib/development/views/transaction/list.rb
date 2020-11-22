# frozen_string_literal: true

module Development
  module Transactions
    module Transaction
      class List
        def self.call(table_name, id) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:transaction, :list, table_name: table_name, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.add_text "#{table_name} - id=#{id}", wrapper: :em
            rules[:transaction_sets].each_with_index do |set, index|
              page.fold_up do |fold|
                fold.open! if index.zero?
                fold.caption set[:caption]
                fold.add_text set[:tx_detail], wrapper: :em if set[:tx_detail]
                fold.add_text set[:status] if set[:status]
                fold.add_table set[:transactions][:rows], set[:transactions][:cols]
              end
            end
          end

          layout
        end
      end
    end
  end
end
