# frozen_string_literal: true

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

  def create_commodity_group(attrs)
    create(:commodity_groups, attrs)
  end

  def find_commodity_group(id)
    find(:commodity_groups, CommodityGroup, id)
  end

  def update_commodity_group(id, attrs)
    update(:commodity_groups, id, attrs)
  end

  def delete_commodity_group(id)
    delete(:commodity_groups, id)
  end

  def create_commodity(attrs)
    create(:commodities, attrs)
  end

  def find_commodity(id)
    find(:commodities, Commodity, id)
  end

  def update_commodity(id, attrs)
    update(:commodities, id, attrs)
  end

  def delete_commodity(id)
    delete(:commodities, id)
  end
end
