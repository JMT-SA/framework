# frozen_string_literal: true

class FruitSizeRepo < RepoBase
  build_for_select :std_fruit_size_counts,
                   label: :size_count_description,
                   value: :id,
                   order_by: :size_count_description
  build_for_select :standard_pack_codes,
                   label: :standard_pack_code,
                   value: :id,
                   order_by: :standard_pack_code
  build_for_select :fruit_size_references,
                   label: :size_reference,
                   value: :id,
                   order_by: :size_reference
  build_for_select :basic_pack_codes,
                   label: :basic_pack_code,
                   value: :id,
                   order_by: :basic_pack_code
  build_for_select :fruit_actual_counts_for_packs,
                   label: :size_count_variation,
                   value: :id,
                   order_by: :size_count_variation

  def create_basic_pack_code(attrs)
    create(:basic_pack_codes, attrs)
  end

  def find_basic_pack_code(id)
    find(:basic_pack_codes, BasicPackCode, id)
  end

  def update_basic_pack_code(id, attrs)
    update(:basic_pack_codes, id, attrs)
  end

  def delete_basic_pack_code(id)
    delete(:basic_pack_codes, id)
  end

  def create_standard_pack_code(attrs)
    create(:standard_pack_codes, attrs)
  end

  def find_standard_pack_code(id)
    find(:standard_pack_codes, StandardPackCode, id)
  end

  def update_standard_pack_code(id, attrs)
    update(:standard_pack_codes, id, attrs)
  end

  def delete_standard_pack_code(id)
    delete(:standard_pack_codes, id)
  end

  def create_fruit_actual_counts_for_pack(attrs)
    create(:fruit_actual_counts_for_packs, attrs)
  end

  def find_fruit_actual_counts_for_pack(id)
    find(:fruit_actual_counts_for_packs, FruitActualCountsForPack, id)
  end

  def update_fruit_actual_counts_for_pack(id, attrs)
    update(:fruit_actual_counts_for_packs, id, attrs)
  end

  def delete_fruit_actual_counts_for_pack(id)
    delete(:fruit_actual_counts_for_packs, id)
  end

  def create_std_fruit_size_count(attrs)
    create(:std_fruit_size_counts, attrs)
  end

  def find_std_fruit_size_count(id)
    find(:std_fruit_size_counts, StdFruitSizeCount, id)
  end

  def update_std_fruit_size_count(id, attrs)
    update(:std_fruit_size_counts, id, attrs)
  end

  def delete_std_fruit_size_count(id)
    delete(:std_fruit_size_counts, id)
  end

  def create_fruit_size_reference(attrs)
    create(:fruit_size_references, attrs)
  end

  def find_fruit_size_reference(id)
    find(:fruit_size_references, FruitSizeReference, id)
  end

  def update_fruit_size_reference(id, attrs)
    update(:fruit_size_references, id, attrs)
  end

  def delete_fruit_size_reference(id)
    delete(:fruit_size_references, id)
  end
end
