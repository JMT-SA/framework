# frozen_string_literal: true

module MasterfilesApp
  class CultivarRepo < RepoBase
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

    # TODO: return cultivar_group_code with cultivar
    # def find_cultivar

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
      orphan_ids = orphaned_marketing_varieties(old_ids)
      DB[:marketing_varieties].where(id: orphan_ids).delete

      new_ids.each do |prog_id|
        DB[:marketing_varieties_for_cultivars].insert(cultivar_id: cultivar_id, marketing_variety_id: prog_id)
      end
      { success: true }
    end

    def orphaned_marketing_varieties(id_set)
      active_ids = DB[:marketing_varieties_for_cultivars].where(marketing_variety_id: id_set).select_map(:marketing_variety_id)
      id_set - active_ids
    end

    def cultivar_marketing_variety_ids(cultivar_id)
      DB[:marketing_varieties_for_cultivars].where(cultivar_id: cultivar_id).select_map(:marketing_variety_id).sort
    end
  end
end
