# frozen_string_literal: true

require 'faker'

# rubocop:disable Metrics/ModuleLength
# rubocop:disable Metrics/AbcSize

module MasterfilesApp
  module PartyFactory
    def create_party(opts = {})
      default = {
        party_type: 'O', # || 'P'
        active: true
      }
      DB[:parties].insert(default.merge(opts))
    end

    def create_person(opts = {})
      party_id = create_party(party_type: 'P')
      default = {
        party_id: party_id,
        title: Faker::Company.name.to_s,
        first_name: Faker::Company.name.to_s,
        surname: Faker::Company.name.to_s,
        vat_number: Faker::Number.number(10),
        active: true
      }
      {
        id: DB[:people].insert(default.merge(opts)),
        party_id: party_id
      }
    end

    def create_organization(opts = {})
      party_id = create_party(party_type: 'O')
      default = {
        party_id: party_id,
        parent_id: nil,
        short_description: Faker::Company.unique.name.to_s,
        medium_description: Faker::Company.name.to_s,
        long_description: Faker::Company.name.to_s,
        vat_number: Faker::Number.number(10),
        active: true
      }
      {
        id: DB[:organizations].insert(default.merge(opts)),
        party_id: party_id
      }
    end

    def create_role(opts = {})
      existing_id = @fixed_table_set[:roles][:"#{opts[:name].downcase}"] if opts[:name]
      return existing_id unless existing_id.nil?
      default = {
        name: Faker::Lorem.unique.word,
        active: true
      }
      {
        id: DB[:roles].insert(default.merge(opts))
      }
    end

    def create_party_role(party_type = 'O', role = nil, opts = {})
      party_id = create_party(party_type: party_type)
      role_id = opts[:role_id] || role ? create_role(name: role)[:id] : create_role[:id]
      default = {
        party_id: party_id,
        role_id: role_id,
        active: true
      }
      default[:organization_id] = create_organization(party_id: party_id)[:id] if party_type == 'O'
      default[:person_id] = create_person(party_id: party_id)[:id] if party_type == 'P'
      final_options = default.merge(opts)
      id = DB[:party_roles].insert(final_options)
      {
        id: id,
        party_id: party_id,
        organization_id: final_options[:organization_id],
        person_id: final_options[:person_id],
        role_id: role_id
      }
    end

    def create_address(opts = {})
      type_id = DB[:address_types].insert(address_type: Faker::Lorem.unique.word)
      default = {
        address_type_id: type_id,
        address_line_1: Faker::Lorem.word,
        address_line_2: Faker::Lorem.word,
        address_line_3: Faker::Lorem.word,
        city: Faker::Lorem.word,
        postal_code: Faker::Number.number(4),
        country: Faker::Lorem.word,
        active: true
      }
      DB[:addresses].insert(default.merge(opts))
    end

    def create_contact_method(opts = {})
      type_id = DB[:contact_method_types].insert(contact_method_type: Faker::Lorem.unique.word)
      default = {
        contact_method_type_id: type_id,
        contact_method_code: Faker::Lorem.word,
        active: true
      }
      DB[:contact_methods].insert(default.merge(opts))
    end

    def create_party_address(opts = {})
      default = {
        party_id: create_party,
        address_id: create_address
      }
      DB[:party_addresses].insert(default.merge(opts))
    end

    def create_party_contact_method(opts = {})
      default = {
        party_id: create_party,
        contact_method_id: create_contact_method
      }
      DB[:party_contact_methods].insert(default.merge(opts))
    end

    def create_supplier_type
      type_code = Faker::Lorem.unique.word
      id = DB[:supplier_types].insert(type_code: type_code)
      {
        id: id,
        type_code: type_code
      }
    end

    def create_customer_type
      type_code = Faker::Lorem.unique.word
      id = DB[:customer_types].insert(type_code: type_code)
      {
        id: id,
        type_code: type_code
      }
    end

    def create_supplier(opts = {})
      party_role_id = create_party_role[:id]
      supplier_type_id = create_supplier_type[:id]
      default = {
        party_role_id: party_role_id,
        erp_supplier_number: Faker::Lorem.unique.word
      }
      supplier_id = DB[:suppliers].insert(default.merge(opts))
      DB[:suppliers_supplier_types].insert(
        supplier_id: supplier_id,
        supplier_type_id: supplier_type_id
      )
      {
        id: supplier_id,
        party_role_id: party_role_id,
        supplier_type_ids: [supplier_type_id]
      }
    end

    def create_customer(opts = {})
      party_role_id = create_party_role[:id]
      customer_type_id = create_customer_type[:id]
      default = {
        party_role_id: party_role_id,
        erp_customer_number: Faker::Lorem.unique.word
      }
      customer_id = DB[:customers].insert(default.merge(opts))
      DB[:customers_customer_types].insert(
        customer_id: customer_id,
        customer_type_id: customer_type_id
      )
      {
        id: customer_id,
        party_role_id: party_role_id,
        customer_type_ids: [customer_type_id]
      }
    end
  end
end
# rubocop:enable Metrics/ModuleLength
# rubocop:enable Metrics/AbcSize
