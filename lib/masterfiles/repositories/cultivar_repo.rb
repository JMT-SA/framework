# frozen_string_literal: true

class CultivarRepo < RepoBase
  def create_cultivar_group(attrs)
    DB[:cultivar_groups].insert(attrs.to_h)
  end

  def find_cultivar_group(id)
    hash = DB[:cultivar_groups].where(id: id).first
    return nil if hash.nil?

    CultivarGroup.new(hash)
  end

  def update_cultivar_group(id, attrs)
    DB[:cultivar_groups].where(id: id).update(attrs.to_h)
  end

  def delete_cultivar_group(id)
    DB[:cultivar_groups].where(id: id).delete
  end

  def cultivar_groups_for_select
    set_for_cultivar_groups
    for_select
  end

  def create_cultivar(attrs)
    DB[:cultivars].insert(attrs.to_h)
  end

  def find_cultivar(id)
    hash = DB[:cultivars].where(id: id).first
    return nil if hash.nil?

    Cultivar.new(hash)
  end

  def update_cultivar(id, attrs)
    DB[:cultivars].where(id: id).update(attrs.to_h)
  end

  def delete_cultivar(id)
    DB[:cultivars].where(id: id).delete
  end

  def create_marketing_variety(cultivar_id, attrs)
    id = DB[:marketing_varieties].insert(attrs.to_h)
    DB[:marketing_varieties_for_cultivars].insert(cultivar_id: cultivar_id, marketing_variety_id: id)
    id
  end

  def find_marketing_variety(id)
    hash = DB[:marketing_varieties].where(id: id).first
    return nil if hash.nil?

    MarketingVariety.new(hash)
  end

  def update_marketing_variety(id, attrs)
    DB[:marketing_varieties].where(id: id).update(attrs.to_h)
  end

  def link_marketing_varieties(cultivar_id, marketing_variety_ids)
    existing_ids      = existing_mv_ids_for_cultivar(cultivar_id)
    old_ids           = existing_ids - marketing_variety_ids
    new_ids           = marketing_variety_ids - existing_ids

    DB.transaction do
      DB[:marketing_varieties_for_cultivars].where(cultivar_id: cultivar_id).where(marketing_variety_id: old_ids).delete
      orphan_ids = orphaned_marketing_varieties(old_ids)
      DB[:marketing_varieties].where(id: orphan_ids).delete

      new_ids.each do |prog_id|
        DB[:marketing_varieties_for_cultivars].insert(cultivar_id: cultivar_id, marketing_variety_id: prog_id)
      end
    end
    { success: true }
  end

  def orphaned_marketing_varieties(id_set)
    active_ids = DB[:marketing_varieties_for_cultivars].where(marketing_variety_id: id_set).select_map(:marketing_variety_id)
    id_set - active_ids
  end

  def existing_mv_ids_for_cultivar(cultivar_id)
    DB[:marketing_varieties_for_cultivars].where(cultivar_id: cultivar_id).select_map(:marketing_variety_id).sort
  end

  def set_for_cultivar_groups
    @main_table_name = :cultivar_groups
    @wrapper = CultivarGroup
    @select_options = {
      label: :cultivar_group_code,
      value: :id,
      order_by: :cultivar_group_code
    }
  end

  def set_for_cultivars
    @main_table_name = :cultivars
    @wrapper = Cultivar
    @select_options = {
      label: :cultivar_name,
      value: :id,
      order_by: :cultivar_name
    }
  end

  def set_for_marketing_varieties
    @main_table_name = :marketing_varieties
    @wrapper = MarketingVariety
    @select_options = {
      label: :marketing_variety_code,
      value: :id,
      order_by: :marketing_variety_code
    }
  end

  def set_for_mv_for_groups
    @main_table_name = :marketing_varieties_for_cultivars
  end

end
