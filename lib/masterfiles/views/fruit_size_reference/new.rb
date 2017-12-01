# frozen_string_literal: true

module Masterfiles
  module Fruit
    module FruitSizeReference
      class New
        def self.call(parent_id, form_values: nil, form_errors: nil, remote: true)
          ui_rule = UiRules::Compiler.new(:fruit_size_reference, :new, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/masterfiles/fruit/fruit_actual_counts_for_packs/#{parent_id}/fruit_size_references"
              form.remote! if remote
              form.add_field :fruit_actual_counts_for_pack_id
              form.add_field :size_reference
            end
          end

          layout
        end
      end
    end
  end
end
