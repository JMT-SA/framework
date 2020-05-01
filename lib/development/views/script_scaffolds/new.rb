module Development
  module Generators
    module ScriptScaffolds
      class New
        def self.call(form_values = nil, form_errors = nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:script_scaffold, :new, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.caption 'Generate a new script'
              form.action '/development/generators/script_scaffolds'
              form.form_id 'gen_form'
              form.add_notice 'Generate the scaffold for a data fix script.<br>Script name must be in CamelCase.<br>Use the description and reason to describe the script well.'
              form.add_field :script_class
              form.add_field :description
              form.add_field :reason
            end
          end

          layout
        end
      end
    end
  end
end
