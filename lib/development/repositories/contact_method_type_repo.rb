# frozen_string_literal: true

class ContactMethodTypeRepo < RepoBase
  build_for_select :contact_method_types,
                   label: :contact_method_type,
                   value: :id,
                   order_by: :contact_method_type

  def create_contact_method_types(attrs)
    create(:contact_method_types, attrs)
  end

  def update_contact_method_types(id, attrs)
    update(:contact_method_types, id, attrs)
  end

  def delete_contact_method_types(id)
    delete(:contact_method_types, id)
  end
end
