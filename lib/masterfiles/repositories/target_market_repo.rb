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

  def create_tm_group_type(attrs)
    create(:target_market_group_types, attrs)
  end

  def find_tm_group_type(id)
    find(:target_market_group_types, TargetMarketGroupType, id)
  end

  def update_tm_group_type(id, attrs)
    update(:target_market_group_types, id, attrs)
  end

  def delete_tm_group_type(id)
    delete(:target_market_group_types, id)
  end

  def create_tm_group(attrs)
    create(:target_market_groups, attrs)
  end

  def find_tm_group(id)
    find(:target_market_groups, TargetMarketGroup, id)
  end

  def update_tm_group(id, attrs)
    update(:target_market_groups, id, attrs)
  end

  def delete_tm_group(id)
    delete(:target_market_groups, id)
  end

  def create_target_market(attrs)
    create(:target_markets, attrs)
  end

  def find_target_market(id)
    hash = find_hash(:target_markets, id)
    return nil if hash.nil?
    hash[:country_ids] = target_market_country_ids(id)
    hash[:tm_group_ids] = target_market_tm_group_ids(id)
    TargetMarket.new(hash)
  end

  def update_target_market(id, attrs)
    update(:target_markets, id, attrs)
  end

  def delete_target_market(id)
    delete(:target_markets, id)
  end

  def link_countries(target_market_id, country_ids)
    existing_ids      = target_market_country_ids(target_market_id)
    old_ids           = existing_ids - country_ids
    new_ids           = country_ids - existing_ids

    DB.transaction do
      DB[:target_markets_for_countries].where(target_market_id: target_market_id).where(destination_country_id: old_ids).delete
      new_ids.each do |prog_id|
        DB[:target_markets_for_countries].insert(target_market_id: target_market_id, destination_country_id: prog_id)
      end
    end
  end

  def target_market_country_ids(target_market_id)
    DB[:target_markets_for_countries].where(target_market_id: target_market_id).select_map(:destination_country_id).sort
  end

  def link_tm_groups(target_market_id, tm_group_ids)
    existing_ids      = target_market_tm_group_ids(target_market_id)
    old_ids           = existing_ids - tm_group_ids
    new_ids           = tm_group_ids - existing_ids

    DB.transaction do
      DB[:target_markets_for_groups].where(target_market_id: target_market_id).where(target_market_group_id: old_ids).delete
      new_ids.each do |prog_id|
        DB[:target_markets_for_groups].insert(target_market_id: target_market_id, target_market_group_id: prog_id)
      end
    end
  end

  def target_market_tm_group_ids(target_market_id)
    DB[:target_markets_for_groups].where(target_market_id: target_market_id).select_map(:target_market_group_id).sort
  end
end
