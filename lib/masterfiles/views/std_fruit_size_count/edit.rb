# frozen_string_literal: true

module Masterfiles
  module Fruit
    module StdFruitSizeCount
      class Edit
        def self.call(id, form_values = nil, form_errors = nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:std_fruit_size_count, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/masterfiles/fruit/std_fruit_size_counts/#{id}"
              form.remote!
              form.method :update
              form.add_field :commodity_id
              form.add_field :size_count_description
              form.add_field :marketing_size_range_mm
              form.add_field :marketing_weight_range
              form.add_field :size_count_interval_group
              form.add_field :size_count_value
              form.add_field :minimum_size_mm
              form.add_field :maximum_size_mm
              form.add_field :average_size_mm
              form.add_field :minimum_weight_gm
              form.add_field :maximum_weight_gm
              form.add_field :average_weight_gm
            end
          end

          layout
        end
      end
    end
  end
end
