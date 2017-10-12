# frozen_string_literal: true

class CommodityRepo < RepoBase
  def initialize
    main_table :commodities
    table_wrapper Commodity
    for_select_options label: :code,
                       value: :id,
                       order_by: :code
  end
end
