# frozen_string_literal: true

module PackMaterial
  module Config
    module MatresType
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:matres_type, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :domain_name
              form.add_field :type_name
              form.add_field :short_code
              form.add_field :description
              form.add_field :internal_seq
            end
          end

          layout
        end
      end
    end
  end
end
