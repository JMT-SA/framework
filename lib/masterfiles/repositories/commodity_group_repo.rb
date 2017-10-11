# frozen_string_literal: true

class CommodityGroupRepo < RepoBase
  def initialize
    main_table :commodity_groups
    table_wrapper CommodityGroup
    for_select_options label: :code,
                       value: :id,
                       order_by: :code
  end
end
