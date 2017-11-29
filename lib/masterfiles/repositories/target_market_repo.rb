# frozen_string_literal: true

class TargetMarketRepo < RepoBase
  build_for_select :target_markets,
                   label: :target_market_name,
                   value: :id,
                   order_by: :target_market_name

  build_for_select :target_market_groups,
                   label: :target_market_group_name,
                   value: :id,
                   order_by: :target_market_group_name

  build_for_select :target_market_group_types,
                   label: :target_market_group_type_code,
                   value: :id,
                   order_by: :target_market_group_type_code

  def tm_group_types_for_select
    set_for_tm_group_types
    for_select
  end

  def tm_groups_for_select
    set_for_tm_groups
    for_select
  end
  # Wrappers:
  # TargetMarketGroup
  # TargetMarketGroupType
  # TargetMarket

  def create_tm_group_type(attrs)
    DB[:target_market_group_types].insert(attrs.to_h)
  end

  def find_tm_group_type(id)
    hash = DB[:target_market_group_types].where(id: id).first
    return nil if hash.nil?
    TargetMarketGroupType.new(hash)
  end

  def update_tm_group_type(id, attrs)
    DB[:target_market_group_types].where(id: id).update(attrs.to_h)
  end

  def delete_tm_group_type(id)
    DB[:target_market_group_types].where(id: id).delete
  end

  def create_tm_group(attrs)
    DB[:target_market_groups].insert(attrs.to_h)
  end

  def find_tm_group(id)
    hash = DB[:target_market_groups].where(id: id).first
    return nil if hash.nil?
    TargetMarketGroup.new(hash)
  end

  def update_tm_group(id, attrs)
    DB[:target_market_groups].where(id: id).update(attrs.to_h)
  end

  def delete_tm_group(id)
    DB[:target_market_groups].where(id: id).delete
  end

  def create_target_market(attrs)
    DB[:target_markets].insert(attrs.to_h)
  end

  def find_target_market(id)
    hash = DB[:target_markets].where(id: id).first
    return nil if hash.nil?
    hash[:country_ids] = existing_country_ids_for_target_market(id)
    hash[:tm_group_ids] = existing_tm_group_ids_for_target_market(id)
    TargetMarket.new(hash)
  end

  def update_target_market(id, attrs)
    DB[:target_markets].where(id: id).update(attrs.to_h)
  end

  def delete_target_market(id)
    DB[:target_markets].where(id: id).delete
  end

  def link_countries(target_market_id, country_ids)
    existing_ids      = existing_country_ids_for_target_market(target_market_id)
    old_ids           = existing_ids - country_ids
    new_ids           = country_ids - existing_ids

    DB.transaction do
      DB[:target_markets_for_countries].where(target_market_id: target_market_id).where(destination_country_id: old_ids).delete
      new_ids.each do |prog_id|
        DB[:target_markets_for_countries].insert(target_market_id: target_market_id, destination_country_id: prog_id)
      end
    end
  end

  def existing_country_ids_for_target_market(target_market_id)
    DB[:target_markets_for_countries].where(target_market_id: target_market_id).select_map(:destination_country_id).sort
  end

  def link_tm_groups(target_market_id, tm_group_ids)
    existing_ids      = existing_tm_group_ids_for_target_market(target_market_id)
    old_ids           = existing_ids - tm_group_ids
    new_ids           = tm_group_ids - existing_ids

    DB.transaction do
      DB[:target_markets_for_groups].where(target_market_id: target_market_id).where(target_market_group_id: old_ids).delete
      new_ids.each do |prog_id|
        DB[:target_markets_for_groups].insert(target_market_id: target_market_id, target_market_group_id: prog_id)
      end
    end
  end

  def existing_tm_group_ids_for_target_market(target_market_id)
    DB[:target_markets_for_groups].where(target_market_id: target_market_id).select_map(:target_market_group_id).sort
  end
end
