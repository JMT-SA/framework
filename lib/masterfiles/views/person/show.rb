# frozen_string_literal: true

module Masterfiles
  module Parties
    module Person
      class Show
        def self.call(id) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:person, :show, id: id)
          rules   = ui_rule.compile
          addresses = MasterfilesApp::PartyRepo.new.addresses_for_party(person_id: id)
          contact_methods = MasterfilesApp::PartyRepo.new.contact_methods_for_party(person_id: id)

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :party_name
              form.add_field :vat_number
              form.add_field :active
              form.add_field :role_names
              form.add_address addresses
              form.add_contact_method contact_methods
            end
          end

          layout
        end
      end
    end
  end
end
