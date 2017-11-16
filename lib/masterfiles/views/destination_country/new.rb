# frozen_string_literal: true

module Masterfiles
  module Fruit
    module DestinationCountry
      class New
        def self.call(form_values: nil, form_errors: nil, remote: true) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:destination_country, :new, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action '/masterfiles/fruit/destination_countries'
              form.remote! if remote
              form.add_field :destination_region_id
              form.add_field :country_name
            end
          end

          layout
        end
      end
    end
  end
end
