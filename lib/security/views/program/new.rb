# frozen_string_literal: true

module Security
  module FunctionalAreas
    module Program
      class New
        def self.call(id, form_values: nil, form_errors: nil, remote: true)
          ui_rule = UiRules::Compiler.new(:program, :new, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action '/security/functional_areas/programs'
              form.remote! if remote
              form.add_field :functional_area_id
              form.add_field :program_name
              form.add_field :program_sequence
              form.add_field :active
            end
          end

          layout
        end
      end
    end
  end
end
