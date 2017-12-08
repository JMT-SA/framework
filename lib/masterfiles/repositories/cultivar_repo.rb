# frozen_string_literal: true

class CultivarRepo < RepoBase
  build_for_select :cultivar_groups,
                   label: :cultivar_group_code,
                   value: :id,
                   order_by: :cultivar_group_code

  build_for_select :cultivars,
                   label: :cultivar_name,
                   value: :id,
                   order_by: :cultivar_name

  build_for_select :marketing_varieties,
                   label: :marketing_variety_code,
                   value: :id,
                   order_by: :marketing_variety_code

  def create_cultivar_group(attrs)
    create(:cultivar_groups, attrs)
  end

  def find_cultivar_group(id)
    find(:cultivar_groups, CultivarGroup, id)
  end

  def update_cultivar_group(id, attrs)
    update(:cultivar_groups, id, attrs)
  end

  def delete_cultivar_group(id)
    delete(:cultivar_groups, id)
  end

  def create_cultivar(attrs)
    create(:cultivars, attrs)
  end

  def find_cultivar(id)
    find(:cultivars, Cultivar, id)
  end

  def update_cultivar(id, attrs)
    update(:cultivars, id, attrs)
  end

  def delete_cultivar(id)
    delete(:cultivars, id)
  end

  def create_marketing_variety(cultivar_id, attrs)
    id = DB[:marketing_varieties].insert(attrs.to_h)
    DB[:marketing_varieties_for_cultivars].insert(cultivar_id: cultivar_id, marketing_variety_id: id)
    id
  end

  def find_marketing_variety(id)
    find(:marketing_varieties, MarketingVariety, id)
  end

  def update_marketing_variety(id, attrs)
    update(:marketing_varieties, id, attrs)
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
