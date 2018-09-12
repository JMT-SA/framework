module Development
  module Generators
    module Scaffolds
      class New
        def self.call(form_values = nil, form_errors = nil)
          ui_rule = UiRules::Compiler.new(:scaffolds, :new, form_values: form_values)
          rules   = ui_rule.compile
          # Apply custom error to its applicable field: # TODO: is there a better way?
          # if form_errors && form_errors[:applet_is_other]
          #   form_errors[:other] = form_errors[:applet_is_other]
          # end

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action '/development/generators/scaffolds'
              form.form_id 'gen_form'
              form.row do |row|
                row.column do |col|
                  col.add_field :table
                  col.add_field :applet
                  col.add_field :other
                  col.add_field :program
                  col.add_field :label_field
                end
                row.column do |col|
                  col.add_field :short_name
                  col.add_field :shared_repo_name
                  col.add_field :nested_route_parent
                  col.add_field :new_from_menu
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
