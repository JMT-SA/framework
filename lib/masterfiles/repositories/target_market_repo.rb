# frozen_string_literal: true

module MasterfilesApp
  class TargetMarketRepo < BaseRepo
    build_for_select :target_market_group_types,
                     alias: 'tm_group_types',
                     label: :target_market_group_type_code,
                     value: :id,
                     order_by: :target_market_group_type_code
    build_inactive_select :target_market_group_types,
                          alias: 'tm_group_types',
                          label: :target_market_group_type_code,
                          value: :id,
                          order_by: :target_market_group_type_code
    build_for_select :target_market_groups,
                     alias: 'tm_groups',
                     label: :target_market_group_name,
                     value: :id,
                     order_by: :target_market_group_name
    build_inactive_select :target_market_groups,
                          alias: 'tm_groups',
                          label: :target_market_group_name,
                          value: :id,
                          order_by: :target_market_group_name
    build_for_select :target_markets,
                     label: :target_market_name,
                     value: :id,
                     order_by: :target_market_name
    build_inactive_select :target_markets,
                          label: :target_market_name,
                          value: :id,
                          order_by: :target_market_name

    crud_calls_for :target_market_group_types, name: :tm_group_type, wrapper: TmGroupType
    crud_calls_for :target_market_groups, name: :tm_group, wrapper: TmGroup
    crud_calls_for :target_markets, name: :target_market, wrapper: TargetMarket

    def find_target_market(id)
      hash = find_hash(:target_markets, id)
      return nil if hash.nil?
      hash[:country_ids] = target_market_country_ids(id)
      hash[:tm_group_ids] = target_market_tm_group_ids(id)
      TargetMarket.new(hash)
    end

    def delete_target_market(id)
      DB[:target_markets_for_countries].where(target_market_id: id).delete
      DB[:target_markets_for_groups].where(target_market_id: id).delete
      DB[:target_markets].where(id: id).delete
    end

    def link_countries(target_market_id, country_ids)
      return nil unless country_ids
      existing_ids      = target_market_country_ids(target_market_id)
      old_ids           = existing_ids - country_ids
      new_ids           = country_ids - existing_ids

      DB[:target_markets_for_countries].where(target_market_id: target_market_id).where(destination_country_id: old_ids).delete
      new_ids.each do |prog_id|
        DB[:target_markets_for_countries].insert(target_market_id: target_market_id, destination_country_id: prog_id)
      end
    end

    def target_market_country_ids(target_market_id)
      DB[:target_markets_for_countries].where(target_market_id: target_market_id).select_map(:destination_country_id).sort
    end

    def link_tm_groups(target_market_id, tm_group_ids)
      return nil unless tm_group_ids
      existing_ids      = target_market_tm_group_ids(target_market_id)
      old_ids           = existing_ids - tm_group_ids
      new_ids           = tm_group_ids - existing_ids

      DB[:target_markets_for_groups].where(target_market_id: target_market_id).where(target_market_group_id: old_ids).delete
      new_ids.each do |prog_id|
        DB[:target_markets_for_groups].insert(target_market_id: target_market_id, target_market_group_id: prog_id)
      end
    end

    def target_market_tm_group_ids(target_market_id)
      DB[:target_markets_for_groups].where(target_market_id: target_market_id).select_map(:target_market_group_id).sort
    end
  end
end
