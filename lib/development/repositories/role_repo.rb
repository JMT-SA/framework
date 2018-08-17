# frozen_string_literal: true

module DevelopmentApp
  class RoleRepo < BaseRepo
    build_for_select :roles,
                     label: :name,
                     value: :id,
                     order_by: :name
    build_inactive_select :roles,
                          label: :name,
                          value: :id,
                          order_by: :name

    crud_calls_for :roles, name: :role, wrapper: Role
  end
end
