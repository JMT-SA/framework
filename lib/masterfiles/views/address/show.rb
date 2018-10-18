# frozen_string_literal: true

module Masterfiles
  module Parties
    module Address
      class Show
        def self.call(id) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:address, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :address_type
              form.add_field :address_line_1
              form.add_field :address_line_2
              form.add_field :address_line_3
              form.add_field :city
              form.add_field :postal_code
              form.add_field :country
              form.add_field :active
            end
          end

          layout
        end
      end
    end
  end
end
