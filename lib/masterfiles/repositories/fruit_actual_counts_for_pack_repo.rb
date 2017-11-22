# frozen_string_literal: true

class FruitActualCountsForPackRepo < RepoBase
  def initialize
    main_table :fruit_actual_counts_for_packs
    table_wrapper FruitActualCountsForPack
    for_select_options label: :size_count_variation,
                       value: :id,
                       order_by: :size_count_variation
  end
end
