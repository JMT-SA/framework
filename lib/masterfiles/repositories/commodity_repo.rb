# frozen_string_literal: true

module MasterfilesApp
  class CommodityRepo < RepoBase
    build_for_select :commodity_groups,
                     label: :code,
                     value: :id,
                     order_by: :code
    build_inactive_select :commodity_groups,
                          label: :code,
                          value: :id

    build_for_select :commodities,
                     label: :code,
                     value: :id,
                     order_by: :code
    build_inactive_select :commodities,
                          label: :code,
                          value: :id

    crud_calls_for :commodity_groups, name: :commodity_group, wrapper: CommodityGroup
    crud_calls_for :commodities, name: :commodity, wrapper: Commodity
  end
end
