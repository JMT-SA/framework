module Security
  module FunctionalAreas
    module SecurityGroup
      class New
        def self.call(form_values: nil, form_errors: nil, remote: true)
          ui_rule = UiRules::Compiler.new(:security_group, :new)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action '/security/functional_areas/security_groups'
              form.remote! if remote
              form.add_field :security_group_name
            end
          end

          layout
        end
      end
    end
  end
end
