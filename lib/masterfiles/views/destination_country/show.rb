# frozen_string_literal: true

module Masterfiles
  module Fruit
    module DestinationCountry
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:destination_country, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :region_name
              form.add_field :country_name
            end
          end

          layout
        end
      end
    end
  end
end
