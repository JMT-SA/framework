# frozen_string_literal: true

module Masterfiles
  module Fruit
    module Cultivar
      class Edit
        def self.call(id, form_values = nil, form_errors = nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:cultivar, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/masterfiles/fruit/cultivars/#{id}"
              form.remote!
              form.method :update
              form.add_field :commodity_id
              form.add_field :cultivar_group_id
              form.add_field :cultivar_name
              form.add_field :description
            end
          end

          layout
        end
      end
    end
  end
end
