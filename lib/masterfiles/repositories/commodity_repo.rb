# frozen_string_literal: true

module MasterfilesApp
  class CommodityRepo < BaseRepo
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

    def delete_commodity(id)
      dependents = DB[:cultivars].where(commodity_id: id).select_map(:id)
      return { error: 'This commodity is in use.' } unless dependents.empty?
      DB[:commodities].where(id: id).delete
      { success: true }
    end

    def delete_commodity_group(id)
      commodities = DB[:commodities].where(commodity_group_id: id).select_map(:id)
      dependents = DB[:cultivars].where(commodity_id: commodities).select_map(:id)
      return { error: 'Some commodities are in use.' } unless dependents.empty?
      commodities.each do |comm_id|
        delete_commodity(comm_id)
      end
      DB[:commodity_groups].where(id: id).delete
      { success: true }
    end
  end
end
