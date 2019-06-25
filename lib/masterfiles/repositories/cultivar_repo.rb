# frozen_string_literal: true

module MasterfilesApp
  class CultivarRepo < BaseRepo
    build_for_select :cultivar_groups,
                     label: :cultivar_group_code,
                     value: :id,
                     no_active_check: true,
                     order_by: :cultivar_group_code

    build_for_select :cultivars,
                     label: :cultivar_name,
                     value: :id,
                     no_active_check: true,
                     order_by: :cultivar_name

    build_for_select :marketing_varieties,
                     label: :marketing_variety_code,
                     value: :id,
                     no_active_check: true,
                     order_by: :marketing_variety_code

    crud_calls_for :cultivar_groups, name: :cultivar_group, wrapper: CultivarGroup
    crud_calls_for :cultivars, name: :cultivar, wrapper: Cultivar
    crud_calls_for :marketing_varieties, name: :marketing_variety, wrapper: MarketingVariety

    def find_cultivar_group(id)
      hash = find_hash(:cultivar_groups, id)
      return nil if hash.nil?

      cultivar_ids = DB[:cultivars].where(cultivar_group_id: id).select_map(:id)
      hash[:cultivar_ids] = cultivar_ids
      CultivarGroup.new(hash)
    end

    def find_cultivar(id)
      hash = find_hash(:cultivars, id)
      return nil if hash.nil?

      cg_hash = find_hash(:cultivar_groups, hash[:cultivar_group_id])
      hash[:cultivar_group_code] = cg_hash[:cultivar_group_code]
      Cultivar.new(hash)
    end

    def delete_cultivar_group(id)
      DB[:cultivar_groups].where(id: id).delete
    end

    def delete_cultivar(id)
      DB[:marketing_varieties_for_cultivars].where(cultivar_id: id).delete
      delete_orphaned_marketing_varieties
      DB[:cultivars].where(id: id).delete
    end

    def create_marketing_variety(cultivar_id, attrs)
      id = DB[:marketing_varieties].insert(attrs.to_h)
      DB[:marketing_varieties_for_cultivars].insert(cultivar_id: cultivar_id, marketing_variety_id: id)
      id
    end

    def link_marketing_varieties(cultivar_id, marketing_variety_ids)
      existing_ids      = cultivar_marketing_variety_ids(cultivar_id)
      old_ids           = existing_ids - marketing_variety_ids
      new_ids           = marketing_variety_ids - existing_ids

      DB[:marketing_varieties_for_cultivars].where(cultivar_id: cultivar_id).where(marketing_variety_id: old_ids).delete
      delete_orphaned_marketing_varieties

      new_ids.each do |prog_id|
        DB[:marketing_varieties_for_cultivars].insert(cultivar_id: cultivar_id, marketing_variety_id: prog_id)
      end
      { success: true }
    end

    def delete_orphaned_marketing_varieties
      link_ids = DB[:marketing_varieties_for_cultivars].select_map(:marketing_variety_id)
      marketing_variety_ids = DB[:marketing_varieties].select_map(:id)
      orphan_ids = marketing_variety_ids - link_ids
      DB[:marketing_varieties].where(id: orphan_ids).delete
    end

    def cultivar_marketing_variety_ids(cultivar_id)
      DB[:marketing_varieties_for_cultivars].where(cultivar_id: cultivar_id).select_map(:marketing_variety_id).sort
    end
  end
end
