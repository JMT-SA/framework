# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/BlockLength

class Framework < Roda
  route 'pack_material_products', 'settings' do |r|
    # MATERIAL RESOURCE DOMAINS
    # --------------------------------------------------------------------------
    r.on 'material_resource_domains', Integer do |id|
      interactor = MaterialResourceDomainInteractor.new(current_user, {}, {}, {})

      # Check for notfound:
      r.on !interactor.exists?(:material_resource_domains, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        if authorised?('Pack material products', 'edit')
          show_partial { Settings::PackMaterialProducts::MaterialResourceDomain::Edit.call(id) }
        else
          dialog_permission_error
        end
      end
      r.is do
        r.get do       # SHOW
          if authorised?('Pack material products', 'read')
            show_partial { Settings::PackMaterialProducts::MaterialResourceDomain::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          response['Content-Type'] = 'application/json'
          res = interactor.update_material_resource_domain(id, params[:material_resource_domain])
          if res.success
            update_grid_row(id, changes: { domain_name: res.instance[:domain_name], product_table_name: res.instance[:product_table_name], variant_table_name: res.instance[:variant_table_name] },
                            notice: res.message)
          else
            content = show_partial { Settings::PackMaterialProducts::MaterialResourceDomain::Edit.call(id, params[:material_resource_domain], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          response['Content-Type'] = 'application/json'
          res = interactor.delete_material_resource_domain(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'material_resource_domains' do
      interactor = MaterialResourceDomainInteractor.new(current_user, {}, {}, {})
      r.on 'new' do    # NEW
        if authorised?('Pack material products', 'new')
          show_partial_or_page(fetch?(r)) { Settings::PackMaterialProducts::MaterialResourceDomain::New.call(remote: fetch?(r)) }
        else
          fetch?(r) ? dialog_permission_error : show_unauthorised
        end
      end
      r.post do        # CREATE
        res = interactor.create_material_resource_domain(params[:material_resource_domain])
        if res.success
          flash[:notice] = res.message
          if fetch?(r)
            redirect_via_json_to_last_grid
          else
            redirect_to_last_grid(r)
          end
        elsif fetch?(r)
          content = show_partial do
            Settings::PackMaterialProducts::MaterialResourceDomain::New.call(form_values: params[:material_resource_domain],
                                                                             form_errors: res.errors,
                                                                             remote: true)
          end
          update_dialog_content(content: content, error: res.message)
        else
          flash[:error] = res.message
          show_page do
            Settings::PackMaterialProducts::MaterialResourceDomain::New.call(form_values: params[:material_resource_domain],
                                                                             form_errors: res.errors,
                                                                             remote: false)
          end
        end
      end
    end
    # MATERIAL RESOURCE TYPES
    # --------------------------------------------------------------------------
    r.on 'material_resource_types', Integer do |id|
      interactor = MaterialResourceInteractor.new(current_user, {}, {}, {})

      # Check for notfound:
      r.on !interactor.exists?(:material_resource_types, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        if authorised?('Pack material products', 'edit')
          show_partial { Settings::PackMaterialProducts::MaterialResourceType::Edit.call(id) }
        else
          dialog_permission_error
        end
      end
      r.is do
        r.get do       # SHOW
          if authorised?('Pack material products', 'read')
            show_partial { Settings::PackMaterialProducts::MaterialResourceType::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          response['Content-Type'] = 'application/json'
          res = interactor.update_material_resource_type(id, params[:material_resource_type])
          if res.success
            update_grid_row(id, changes: { material_resource_domain_id: res.instance[:material_resource_domain_id], type_name: res.instance[:type_name] },
                            notice: res.message)
          else
            content = show_partial { Settings::PackMaterialProducts::MaterialResourceType::Edit.call(id, params[:material_resource_type], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          response['Content-Type'] = 'application/json'
          res = interactor.delete_material_resource_type(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'material_resource_types' do
      interactor = MaterialResourceInteractor.new(current_user, {}, {}, {})
      r.on 'new' do    # NEW
        if authorised?('Pack material products', 'new')
          show_partial_or_page(fetch?(r)) { Settings::PackMaterialProducts::MaterialResourceType::New.call(remote: fetch?(r)) }
        else
          fetch?(r) ? dialog_permission_error : show_unauthorised
        end
      end
      r.post do        # CREATE
        res = interactor.create_material_resource_type(params[:material_resource_type])
        if res.success
          flash[:notice] = res.message
          if fetch?(r)
            redirect_via_json_to_last_grid
          else
            redirect_to_last_grid(r)
          end
        elsif fetch?(r)
          content = show_partial do
            Settings::PackMaterialProducts::MaterialResourceType::New.call(form_values: params[:material_resource_type],
                                                                           form_errors: res.errors,
                                                                           remote: true)
          end
          update_dialog_content(content: content, error: res.message)
        else
          flash[:error] = res.message
          show_page do
            Settings::PackMaterialProducts::MaterialResourceType::New.call(form_values: params[:material_resource_type],
                                                                           form_errors: res.errors,
                                                                           remote: false)
          end
        end
      end
    end
    # MATERIAL RESOURCE SUB TYPES
    # --------------------------------------------------------------------------
    r.on 'material_resource_sub_types', Integer do |id|
      interactor = MaterialResourceInteractor.new(current_user, {}, {}, {})

      # Check for notfound:
      r.on !interactor.exists?(:material_resource_sub_types, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        if authorised?('Pack material products', 'edit')
          show_partial { Settings::PackMaterialProducts::MaterialResourceSubType::Edit.call(id) }
        else
          dialog_permission_error
        end
      end
      r.on 'config' do  # MR type config edit
        r.is 'edit' do
          if authorised?('Pack material products', 'edit')
            show_page { Settings::PackMaterialProducts::MaterialResourceSubType::Config.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          response['Content-Type'] = 'application/json'
          config = PackMaterialRepo.new.find_material_resource_type_config_for_sub_type(id)
          config_id = config.id
          res = interactor.update_material_resource_type_config(config_id, params[:material_resource_sub_type])
          if res.success
            # flash[:notice] = res.message
            if fetch?(r)
              # redirect_via_json_to_last_grid
              show_json_notice(res.message) # TODO: Should also be able to re-enable submit button...
            else
              redirect_to_last_grid(r)
            end
          else
            # TODO: test that this is working
            p "Did we get in here now?"
            content = show_page { Settings::PackMaterialProducts::MaterialResourceSubType::Config.call(id, params[:material_resource_sub_type], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
      end
      r.is do
        r.get do       # SHOW
          if authorised?('Pack material products', 'read')
            show_partial { Settings::PackMaterialProducts::MaterialResourceSubType::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          response['Content-Type'] = 'application/json'
          res = interactor.update_material_resource_sub_type(id, params[:material_resource_sub_type])
          if res.success
            update_grid_row(id, changes: { material_resource_type_id: res.instance[:material_resource_type_id], sub_type_name: res.instance[:sub_type_name] },
                            notice: res.message)
          else
            content = show_partial { Settings::PackMaterialProducts::MaterialResourceSubType::Edit.call(id, params[:material_resource_sub_type], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          response['Content-Type'] = 'application/json'
          res = interactor.delete_material_resource_sub_type(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'material_resource_sub_types' do
      interactor = MaterialResourceInteractor.new(current_user, {}, {}, {})
      r.on 'new' do    # NEW
        if authorised?('Pack material products', 'new')
          show_partial_or_page(fetch?(r)) { Settings::PackMaterialProducts::MaterialResourceSubType::New.call(remote: fetch?(r)) }
        else
          fetch?(r) ? dialog_permission_error : show_unauthorised
        end
      end
      r.post do        # CREATE
        res = interactor.create_material_resource_sub_type(params[:material_resource_sub_type])
        if res.success
          flash[:notice] = res.message
          if fetch?(r)
            redirect_via_json_to_last_grid
          else
            redirect_to_last_grid(r)
          end
        elsif fetch?(r)
          content = show_partial do
            Settings::PackMaterialProducts::MaterialResourceSubType::New.call(form_values: params[:material_resource_sub_type],
                                                                              form_errors: res.errors,
                                                                              remote: true)
          end
          update_dialog_content(content: content, error: res.message)
        else
          flash[:error] = res.message
          show_page do
            Settings::PackMaterialProducts::MaterialResourceSubType::New.call(form_values: params[:material_resource_sub_type],
                                                                              form_errors: res.errors,
                                                                              remote: false)
          end
        end
      end
    end
    r.on 'link_mr_product_columns', Integer do |id| # TODO: This does not have to be per id....
      r.post do
        interactor = MaterialResourceInteractor.new(current_user, {}, {}, {})
        res = interactor.chosen_product_columns(multiselect_grid_choices(params))
        json_actions([OpenStruct.new(type: :replace_multi_options, dom_id: 'product_code_columns_non_variant_product_code_column_ids', options_array: res.instance[:code]),
                      OpenStruct.new(type: :replace_multi_options, dom_id: 'product_code_columns_variant_product_code_column_ids', options_array: res.instance[:var])],
                     'Re-assigned product columns')
      end
    end
    r.on 'link_mr_product_code_columns', Integer do |id|
      r.post do
        interactor = MaterialResourceInteractor.new(current_user, {}, {}, {})

        res = interactor.link_mr_product_code_columns(id, multiselect_grid_choices(params))
        if res.success
          flash[:notice] = res.message
        else
          flash[:error] = res.message
        end
        redirect_to_last_grid(r)
        # TODO: fix this redirect
        # r.redirect("/settings/pack_material_products/material_resource_sub_types/#{res.instance.id}/config/edit")
      end
    end
    r.on 'assign_product_code_columns', Integer do |id|
      r.post do
        interactor = MaterialResourceInteractor.new(current_user, {}, {}, {})

        res = interactor.assign_non_variant_product_code_columns(id, params[:product_code_columns])
        if res.success
          flash[:notice] = res.message
        else
          flash[:error] = res.message
        end
        redirect_to_last_grid(r)
        # TODO: fix this redirect
        # r.redirect("/settings/pack_material_products/material_resource_sub_types/#{res.instance.id}/config/edit")
      end
    end
    r.on 'assign_variant_product_code_columns', Integer do |id|
      r.post do
        interactor = MaterialResourceInteractor.new(current_user, {}, {}, {})

        res = interactor.assign_variant_product_code_columns(id, params[:variant_product_code_columns])
        if res.success
          flash[:notice] = res.message
        else
          flash[:error] = res.message
        end
        redirect_to_last_grid(r)
        # TODO: fix this redirect
        # r.redirect("/settings/pack_material_products/material_resource_sub_types/#{res.instance.id}/config/edit")
      end
    end
    r.on 'reorder_product_code_columns', Integer do |id|
      r.post do
        interactor = MaterialResourceInteractor.new(current_user, {}, {}, {})

        res = interactor.reorder_product_code_columns(id, params[:columncodes_sorted_ids])
        if res.success
          flash[:notice] = res.message
        else
          flash[:error] = res.message
        end
        redirect_to_last_grid(r)
        r.redirect("/settings/pack_material_products/material_resource_sub_types/#{id}/config/edit")
      end
    end

    # MATERIAL RESOURCE PRODUCT COLUMNS
    # --------------------------------------------------------------------------
    r.on 'material_resource_product_columns', Integer do |id|
      interactor = MaterialResourceProductColumnInteractor.new(current_user, {}, {}, {})

      # Check for notfound:
      r.on !interactor.exists?(:material_resource_product_columns, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        if authorised?('Pack material products', 'edit')
          show_partial { Settings::PackMaterialProducts::MaterialResourceProductColumn::Edit.call(id) }
        else
          dialog_permission_error
        end
      end
      r.is do
        r.get do       # SHOW
          if authorised?('Pack material products', 'read')
            show_partial { Settings::PackMaterialProducts::MaterialResourceProductColumn::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          response['Content-Type'] = 'application/json'
          res = interactor.update_material_resource_product_column(id, params[:material_resource_product_column])
          if res.success
            update_grid_row(id, changes: { material_resource_domain_id: res.instance[:material_resource_domain_id], column_name: res.instance[:column_name], group_name: res.instance[:group_name], is_variant_column: res.instance[:is_variant_column] },
                            notice: res.message)
          else
            content = show_partial { Settings::PackMaterialProducts::MaterialResourceProductColumn::Edit.call(id, params[:material_resource_product_column], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          response['Content-Type'] = 'application/json'
          res = interactor.delete_material_resource_product_column(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'material_resource_product_columns' do
      interactor = MaterialResourceProductColumnInteractor.new(current_user, {}, {}, {})
      r.on 'new' do    # NEW
        if authorised?('Pack material products', 'new')
          show_partial_or_page(fetch?(r)) { Settings::PackMaterialProducts::MaterialResourceProductColumn::New.call(remote: fetch?(r)) }
        else
          fetch?(r) ? dialog_permission_error : show_unauthorised
        end
      end
      r.post do        # CREATE
        res = interactor.create_material_resource_product_column(params[:material_resource_product_column])
        if res.success
          flash[:notice] = res.message
          if fetch?(r)
            redirect_via_json_to_last_grid
          else
            redirect_to_last_grid(r)
          end
        elsif fetch?(r)
          content = show_partial do
            Settings::PackMaterialProducts::MaterialResourceProductColumn::New.call(form_values: params[:material_resource_product_column],
                                                                                    form_errors: res.errors,
                                                                                    remote: true)
          end
          update_dialog_content(content: content, error: res.message)
        else
          flash[:error] = res.message
          show_page do
            Settings::PackMaterialProducts::MaterialResourceProductColumn::New.call(form_values: params[:material_resource_product_column],
                                                                                    form_errors: res.errors,
                                                                                    remote: false)
          end
        end
      end
    end
    # PACK MATERIAL PRODUCTS
    # --------------------------------------------------------------------------
    r.on 'pack_material_products', Integer do |id|
      interactor = PackMaterialProductInteractor.new(current_user, {}, {}, {})

      # check for notfound
      r.on !interactor.exists?(:pack_material_products, id) do
        handle_not_found(r)
      end

      r.on 'edit' do
        if authorized?('Pack Material Products', 'edit')
          show_partial { Settings::PackMaterialProducts::PackMaterialProduct::Edit.call(id) }
        else
          dialog_permission_error
        end
      end
      r.is do
        r.get do       # SHOW
          if authorised?('Pack material products', 'read')
            show_partial { Settings::PackMaterialProducts::PackMaterialProduct::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          response['Content-Type'] = 'application/json'
          res = interactor.update_pack_material_product(id, params[:pack_material_product])
          if res.success
            update_grid_row(id, changes: { material_resource_sub_type_id: res.instance[:material_resource_sub_type_id],
                                           product_number: res.instance[:product_number],
                                           description: res.instance[:description],
                                           commodity_id: res.instance[:commodity_id],
                                           variety_id: res.instance[:variety_id],
                                           style: res.instance[:style],
                                           assembly_type: res.instance[:assembly_type],
                                           market_major: res.instance[:market_major],
                                           ctn_size_basic_pack: res.instance[:ctn_size_basic_pack],
                                           ctn_size_old_pack: res.instance[:ctn_size_old_pack],
                                           pls_pack_code: res.instance[:pls_pack_code],
                                           fruit_mass_nett_kg: res.instance[:fruit_mass_nett_kg],
                                           holes: res.instance[:holes],
                                           perforation: res.instance[:perforation],
                                           image: res.instance[:image],
                                           length_mm: res.instance[:length_mm],
                                           width_mm: res.instance[:width_mm],
                                           height_mm: res.instance[:height_mm],
                                           diameter_mm: res.instance[:diameter_mm],
                                           thick_mm: res.instance[:thick_mm],
                                           thick_mic: res.instance[:thick_mic],
                                           colour: res.instance[:colour],
                                           grade: res.instance[:grade],
                                           mass: res.instance[:mass],
                                           material_type: res.instance[:material_type],
                                           treatment: res.instance[:treatment],
                                           specification_notes: res.instance[:specification_notes],
                                           artwork_commodity: res.instance[:artwork_commodity],
                                           artwork_marketing_variety_group: res.instance[:artwork_marketing_variety_group],
                                           artwork_variety: res.instance[:artwork_variety],
                                           artwork_nett_mass: res.instance[:artwork_nett_mass],
                                           artwork_brand: res.instance[:artwork_brand],
                                           artwork_class: res.instance[:artwork_class],
                                           artwork_plu_number: res.instance[:artwork_plu_number],
                                           artwork_other: res.instance[:artwork_other],
                                           artwork_image: res.instance[:artwork_image],
                                           marketer: res.instance[:marketer],
                                           retailer: res.instance[:retailer],
                                           supplier: res.instance[:supplier],
                                           supplier_stock_code: res.instance[:supplier_stock_code],
                                           product_alternative: res.instance[:product_alternative],
                                           product_joint_use: res.instance[:product_joint_use],
                                           ownership: res.instance[:ownership],
                                           consignment_stock: res.instance[:consignment_stock],
                                           start_date: res.instance[:start_date],
                                           end_date: res.instance[:end_date],
                                           active: res.instance[:active],
                                           remarks: res.instance[:remarks] },
                            notice: res.message)
          else
            content = show_partial { Settings::PackMaterialProducts::PackMaterialProduct::Edit.call(id, params[:pack_material_product], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          response['Content-Type'] = 'application/json'
          res = interactor.delete_pack_material_product(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'pack_material_products' do
      p "in here"
      interactor = PackMaterialProductInteractor.new(current_user, {}, {}, {})
      r.on 'new' do    # NEW
        p "on new"
        if authorised?('Pack Material Products', 'new')
          show_partial_or_page(fetch?(r)) { Settings::PackMaterialProducts::PackMaterialProduct::New.call(remote: fetch?(r)) }
        else
          fetch?(r) ? dialog_permission_error : show_unauthorised
        end
      end
      r.post do        # CREATE
        res = interactor.create_pack_material_product(params[:pack_material_product])
        if res.success
          flash[:notice] = res.message
          if fetch?(r)
            redirect_via_json_to_last_grid
          else
            redirect_to_last_grid(r)
          end
        elsif fetch?(r)
          content = show_partial do
            Settings::PackMaterialProducts::PackMaterialProduct::New.call(form_values: params[:pack_material_product],
                                                                          form_errors: res.errors,
                                                                          remote: true)
          end
          update_dialog_content(content: content, error: res.message)
        else
          flash[:error] = res.message
          show_page do
            Settings::PackMaterialProducts::PackMaterialProduct::New.call(form_values: params[:pack_material_product],
                                                                          form_errors: res.errors,
                                                                          remote: false)
          end
        end
      end
    end
  end
end
