# frozen_string_literal: true

module Masterfiles
  module Parties
    module Person
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:person, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              # form.add_field :party_id
              form.add_field :title
              form.add_field :first_name
              form.add_field :surname
              form.add_field :vat_number
              # form.add_field :active
              # form.add_field :roles
            end
          end

          layout
        end
      end
    end
  end
end
