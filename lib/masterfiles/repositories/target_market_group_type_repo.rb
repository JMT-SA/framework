# frozen_string_literal: true

class TargetMarketGroupTypeRepo < RepoBase
  def initialize
    main_table :target_market_group_types
    table_wrapper TargetMarketGroupType
    for_select_options label: :target_market_group_type_code,
                       value: :id,
                       order_by: :target_market_group_type_code
  end
end
