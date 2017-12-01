# frozen_string_literal: true

class StdFruitSizeCountRepo < RepoBase
  def initialize
    main_table :std_fruit_size_counts
    table_wrapper StdFruitSizeCount
    for_select_options label: :size_count_description,
                       value: :id,
                       order_by: :size_count_description
  end
end
