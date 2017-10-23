# frozen_string_literal: true

class OrganizationRepo < RepoBase
  def initialize
    main_table :organizations
    table_wrapper Organization
    for_select_options label: :short_description,
                       value: :id,
                       order_by: :short_description
  end

  def create_organization(attrs)
    params = attrs.to_h
    role_id = params.delete(:role_id)
    params[:medium_description] = params[:short_description] unless params[:medium_description]
    params[:long_description] = params[:short_description] unless params[:long_description]
    DB.transaction do # BEGIN
      party_id = DB[:parties].insert(party_type: 'O')
      org_id = DB[:organizations].insert(params.merge(party_id: party_id))
      DB[:party_roles].insert(organization_id: org_id,
                              party_id: party_id,
                              role_id: role_id)
    end
  end
end
