# frozen_string_literal: true

class CultivarRepo < RepoBase
  def initialize
    main_table :cultivars
    table_wrapper Cultivar
    for_select_options label: :cultivar_name,
                       value: :id,
                       order_by: :cultivar_name
  end
end
