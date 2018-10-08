# frozen_string_literal: true

module Masterfiles
  module Fruit
    module StdFruitSizeCount
      class New
        def self.call(form_values: nil, form_errors: nil, remote: true) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:std_fruit_size_count, :new, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page| # rubocop:disable Metrics/BlockLength
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form| # rubocop:disable Metrics/BlockLength
              form.action '/masterfiles/fruit/std_fruit_size_counts'
              form.remote! if remote
              form.row do |row|
                row.column do |col|
                  col.add_field :commodity_id
                  col.add_field :size_count_description
                  col.add_field :marketing_size_range_mm
                  col.add_field :marketing_weight_range
                  col.add_field :size_count_interval_group
                  col.add_field :size_count_value
                end
              end
              form.row do |row|
                # row.column do |col|
                #   col.add_text "Label"
                # end
                row.column do |col|
                  col.add_field :minimum_size_mm
                end
                row.column do |col|
                  col.add_field :maximum_size_mm
                end
                row.column do |col|
                  col.add_field :average_size_mm
                end
              end
              form.row do |row|
                row.column do |col|
                  col.add_field :minimum_weight_gm
                  col.add_field :maximum_weight_gm
                  col.add_field :average_weight_gm
                end
              end
            end
          end

          layout
        end
      end
    end
  end
end
