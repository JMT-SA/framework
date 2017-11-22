# frozen_string_literal: true

class FruitSizeReferenceRepo < RepoBase
  def initialize
    main_table :fruit_size_references
    table_wrapper FruitSizeReference
    for_select_options label: :size_reference,
                       value: :id,
                       order_by: :size_reference
  end
end
