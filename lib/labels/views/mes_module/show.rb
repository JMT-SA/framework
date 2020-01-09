# frozen_string_literal: true

module Labels
  module Designs
    module MesModule
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:mes_module, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              # form.caption 'Mes Module'
              form.view_only!
              form.add_field :module_code
              form.add_field :module_type
              form.add_field :server_ip
              form.add_field :ip_address
              form.add_field :port
              form.add_field :alias
              form.add_field :active
            end
          end

          layout
        end
      end
    end
  end
end
