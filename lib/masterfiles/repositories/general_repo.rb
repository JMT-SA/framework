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

    build_for_select :account_codes,
                     label: :account_code,
                     value: :id,
                     no_active_check: true,
                     order_by: :account_code

    crud_calls_for :account_codes, name: :account_code, wrapper: AccountCode

    def find_uom(id)
      find_with_association(:uoms, id,
                            parent_tables: [{ parent_table: :uom_types, flatten_columns: { code: :uom_type_code } }],
                            wrapper: MasterfilesApp::Uom)
    end

    def for_select_account_codes_with_descriptions
      DB["SELECT account_codes.id,
                 concat(account_code, ' (', description, ')') as desc
        from account_codes"].all.map { |r| [r[:desc], r[:id]] }
    end

    def default_purchase_order_account_code_id
      for_select_account_codes(where: { account_code:  AppConst::PO_ACCOUNT_CODE }).first.first
    end
  end
end
