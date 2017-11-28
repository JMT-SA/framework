module Security
  module FunctionalAreas
    module SecurityPermission
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:security_permission, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.add_field :security_permission
              form.view_only!
            end
          end

          layout
        end
      end
    end
  end
end
