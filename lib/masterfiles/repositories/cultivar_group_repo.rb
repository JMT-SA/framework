# frozen_string_literal: true

class CultivarGroupRepo < RepoBase
  def initialize
    main_table :cultivar_groups
    table_wrapper CultivarGroup
    for_select_options label: :cultivar_group_code,
                       value: :id,
                       order_by: :cultivar_group_code
  end
end
