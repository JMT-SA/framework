# frozen_string_literal: true

module Masterfiles
  module Fruit
    module FruitActualCountsForPack
      class New
        def self.call(parent_id, form_values: nil, form_errors: nil, remote: true)
          ui_rule = UiRules::Compiler.new(:fruit_actual_counts_for_pack, :new, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/masterfiles/fruit/std_fruit_size_counts/#{parent_id}/fruit_actual_counts_for_packs"
              form.remote! if remote
              # form.add_field :std_fruit_size_count_id
              form.add_field :basic_pack_code_id
              form.add_field :standard_pack_code_id
              form.add_field :actual_count_for_pack
              form.add_field :size_count_variation
            end
          end

          layout
        end
      end
    end
  end
end
