# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/BlockLength

class Framework < Roda
  route 'material_resource', 'pack_material' do |r|
    # MATERIAL RESOURCE PRODUCT VARIANTS
    # --------------------------------------------------------------------------
    r.on 'material_resource_product_variants', Integer do |id|
      interactor = PackMaterialApp::MatresProductVariantInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:material_resource_product_variants, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('material_resource', 'edit')
        show_partial { PackMaterial::MaterialResource::MatresProductVariant::Edit.call(id) }
      end
      r.on 'material_resource_product_variant_party_roles' do
        # Merge these interactors
        role_interactor = PackMaterialApp::MatresProductVariantPartyRoleInteractor.new(current_user, {}, { route_url: request.path }, {})
        r.on 'new' do    # NEW
          check_auth!('material_resource', 'new')
          type = params[:type]
          show_partial_or_page(r) { PackMaterial::MaterialResource::MatresProductVariantPartyRole::New.call(id, type) }
        end
        r.post do        # CREATE
          res = role_interactor.create_matres_product_variant_party_role(id, params[:matres_product_variant_party_role])
          type = params[:type]
          if res.success
            reload_previous_dialog_via_json("/list/material_resource_product_variant_party_roles/with_params?matres_variant_id=#{id}", notice: res.message)
          else
            re_show_form(r, res, url: "/pack_material/material_resource/material_resource_product_variants/#{id}/material_resource_product_variant_party_roles/new?type=#{type}") do
              PackMaterial::MaterialResource::MatresProductVariantPartyRole::New.call(id,
                                                                                      type,
                                                                                      form_values: params[:matres_product_variant_party_role],
                                                                                      form_errors: res.errors,
                                                                                      remote: fetch?(r))
            end
          end
        end
      end
      r.is do
        r.get do       # SHOW
          check_auth!('material_resource', 'read')
          show_partial { PackMaterial::MaterialResource::MatresProductVariant::Show.call(id) }
        end
        r.patch do     # UPDATE
          return_json_response
          res = interactor.update_matres_product_variant(id, params[:matres_product_variant])
          if res.success
            row_keys = %i[
              old_product_code
              supplier_lead_time
              minimum_stock_level
              re_order_stock_level
            ]
            parent_variant_id = res.instance[:product_variant_id]
            update_grid_row(parent_variant_id, changes: select_attributes(res.instance, row_keys), notice: res.message)
          else
            content = show_partial { PackMaterial::MaterialResource::MatresProductVariant::Edit.call(id, form_values: params[:matres_product_variant], form_errors: res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        # r.delete do    # DELETE
        #   return_json_response
        #   check_auth!('material_resource', 'delete')
        #   res = interactor.delete_matres_product_variant(id)
        #   delete_grid_row(id, notice: res.message)
        # end
      end
    end
    # MATERIAL RESOURCE PRODUCT VARIANT PARTY ROLES
    # --------------------------------------------------------------------------
    r.on 'material_resource_product_variant_party_roles', Integer do |id|
      interactor = PackMaterialApp::MatresProductVariantPartyRoleInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:material_resource_product_variant_party_roles, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('material_resource', 'edit')
        show_partial { PackMaterial::MaterialResource::MatresProductVariantPartyRole::Edit.call(id) }
      end
      r.is do
        r.get do       # SHOW
          check_auth!('material_resource', 'read')
          show_partial { PackMaterial::MaterialResource::MatresProductVariantPartyRole::Show.call(id) }
        end
        r.patch do     # UPDATE
          return_json_response
          res = interactor.update_matres_product_variant_party_role(id, params[:matres_product_variant_party_role])
          if res.success
            row_keys = %i[
              material_resource_product_variant_id
              supplier_id
              customer_id
              party_stock_code
              supplier_lead_time
              is_preferred_supplier
            ]
            update_grid_row(id, changes: select_attributes(res.instance, row_keys), notice: res.message)
          else
            content = show_partial { PackMaterial::MaterialResource::MatresProductVariantPartyRole::Edit.call(id, form_values: params[:matres_product_variant_party_role], form_errors: res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          return_json_response
          check_auth!('material_resource', 'delete')
          res = interactor.delete_matres_product_variant_party_role(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'link_alternative_material_resource_product_variants', Integer do |id|
      r.post do
        interactor = PackMaterialApp::MatresProductVariantInteractor.new(current_user, {}, { route_url: request.path }, {})

        res = interactor.link_alternatives(id, multiselect_grid_choices(params))
        if res.success
          flash[:notice] = res.message
        else
          flash[:error] = res.message
        end
        redirect_to_last_grid(r)
      end
    end
    r.on 'link_co_use_material_resource_product_variants', Integer do |id|
      r.post do
        interactor = PackMaterialApp::MatresProductVariantInteractor.new(current_user, {}, { route_url: request.path }, {})

        res = interactor.link_co_use_product_codes(id, multiselect_grid_choices(params))
        if res.success
          flash[:notice] = res.message
        else
          flash[:error] = res.message
        end
        redirect_to_last_grid(r)
      end
    end
  end
end

# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/BlockLength
