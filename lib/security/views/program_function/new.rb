module Security
  module FunctionalAreas
    module ProgramFunction
      class New
        def self.call(id, form_values: nil, form_errors: nil, remote: true) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:program_function, :new, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action '/security/functional_areas/program_functions/create'
              form.remote! if remote
              form.add_field :program_id
              form.add_field :program_function_name
              form.add_field :group_name
              form.add_field :url
              form.add_field :program_function_sequence
              form.add_field :restricted_user_access
              form.add_field :active
              form.add_field :show_in_iframe
            end
          end

          layout
        end
      end
    end
  end
end
