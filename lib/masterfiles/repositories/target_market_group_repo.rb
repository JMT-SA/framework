# frozen_string_literal: true

class TargetMarketGroupRepo < RepoBase
  def initialize
    main_table :target_market_groups
    table_wrapper TargetMarketGroup
    for_select_options label: :target_market_group_name,
                       value: :id,
                       order_by: :target_market_group_name
  end
end
