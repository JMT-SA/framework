# frozen_string_literal: true

class AddressTypeRepo < RepoBase
  build_for_select :address_types,
                   label: :address_type,
                   value: :id,
                   order_by: :address_type

  def create_address_type(attrs)
    create(:address_types, attrs)
  end

  def update_address_type(id, attrs)
    update(:address_types, id, attrs)
  end

  def delete_address_type(id)
    delete(:address_types, id)
  end
end
