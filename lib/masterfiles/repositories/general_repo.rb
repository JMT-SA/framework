# frozen_string_literal: true

module MasterfilesApp
  class GeneralRepo < BaseRepo
    build_for_select :uom_types,
                     label: :code,
                     value: :id,
                     no_active_check: true,
                     order_by: :code

    crud_calls_for :uom_types, name: :uom_type, wrapper: UomType

    build_for_select :uoms,
                     label: :uom_code,
                     value: :id,
                     no_active_check: true,
                     order_by: :uom_code

    crud_calls_for :uoms, name: :uom, wrapper: Uom
  end
end
