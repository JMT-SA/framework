# frozen_string_literal: true

class CommodityRepo < RepoBase
  def create_commodity_group(attrs)
    DB[:commodity_groups].insert(attrs.to_h)
  end

  def find_commodity_group(id)
    hash = DB[:commodity_groups].where(id: id).first
    return nil if hash.nil?
    CommodityGroup.new(hash)
  end

  def update_commodity_group(id, attrs)
    DB[:commodity_groups].where(id: id).update(attrs.to_h)
  end

  def delete_commodity_group(id)
    DB[:commodity_groups].where(id: id).delete
  end

  def create_commodity(attrs)
    DB[:commodities].insert(attrs.to_h)
  end

  def find_commodity(id)
    hash = DB[:commodities].where(id: id).first
    return nil if hash.nil?
    Commodity.new(hash)
  end

  def update_commodity(id, attrs)
    DB[:commodities].where(id: id).update(attrs.to_h)
  end

  def delete_commodity(id)
    DB[:commodities].where(id: id).delete
  end

  def commodity_groups_for_select
    set_for_commodity_groups
    for_select
  end

  def commodities_for_select
    set_for_commodities
    for_select
  end

  def set_for_commodity_groups
    @main_table_name = :commodity_groups
    @wrapper = CommodityGroup
    @select_options = {
      label: :code,
      value: :id,
      order_by: :code
    }
  end

  def set_for_commodities
    @main_table_name = :commodities
    @wrapper = Commodity
    @select_options = {
      label: :code,
      value: :id,
      order_by: :code
    }
  end

end