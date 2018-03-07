# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/BlockLength

class Framework < Roda
  route 'config', 'pack_material' do |r|
    # MATERIAL RESOURCE TYPES
    # --------------------------------------------------------------------------
    r.on 'material_resource_types', Integer do |id|
      interactor = PackMaterialApp::ConfigInteractor.new(current_user, {}, {}, {})

      # Check for notfound:
      r.on !interactor.exists?(:material_resource_types, id) do
        handle_not_found(r)
      end

      r.on 'edit' do
        if authorised?('Pack material products', 'edit') #???
          show_partial { PackMaterialApp::Config::MatresType::Edit.call(id) }
        else
          dialog_permission_error
        end
      end
      r.is do
        r.get do
          if authorised?('Pack material products', 'read') #???
            show_partial { PackMaterialApp::Config::MatresType::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do
          response['Content-Type'] = 'application/json'
          res = interactor.update_matres_type(id, params[:matres_type])
          if res.success
            update_grid_row(id, changes: { material_resource_domain_id: res.instance[:material_resource_domain_id],
                                           type_name: res.instance[:type_name] },
                            notice: res.message)
          else
            content = show_partial { PackMaterialApp::Config::MatresType::Edit.call(id, params[:matres_type], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do
          response['Content-Type'] = 'application/json'
          res = interactor.delete_matres_type(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'material_resource_types' do
      interactor = PackMaterialApp::ConfigInteractor.new(current_user, {}, {}, {})
      r.on 'new' do
        if authorised?('Pack material products', 'new')
          show_partial_or_page(fetch?(r)) { PackMaterialApp::Config::MatresType::New.call(remote: fetch?(r)) }
        else
          fetch?(r) ? dialog_permission_error : show_unauthorised
        end
      end
      r.post do
        res = interactor.create_matres_type(params[:matres_type])
        if res.success
          flash[:notice] = res.message
          if fetch?(r)
            redirect_via_json_to_last_grid
          else
            redirect_to_last_grid(r)
          end
        elsif fetch?(r)
          content = show_partial do
            PackMaterialApp::Config::MatresType::New.call(form_values: params[:matres_type],
                                                          form_errors: res.errors,
                                                          remote: true)
          end
          update_dialog_content(content: content, error: res.message)
        else
          flash[:error] = res.message
          show_page do
            PackMaterialApp::Config::MatresType::New.call(form_values: params[:matres_type],
                                                          form_errors: res.errors,
                                                          remote: false)
          end
        end
      end
    end
    # MATERIAL RESOURCE SUB TYPES
    # --------------------------------------------------------------------------
    r.on 'material_resource_sub_types', Integer do |id|
      interactor = PackMaterialApp::ConfigInteractor.new(current_user, {}, {}, {})

      # Check for notfound:
      r.on !interactor.exists?(:material_resource_sub_types, id) do
        handle_not_found(r)
      end

      r.on 'edit' do
        if authorised?('Pack material products', 'edit')
          show_partial { PackMaterialApp::Config::MatresSubType::Edit.call(id) }
        else
          dialog_permission_error
        end
      end
      r.on 'config' do
        r.is 'edit' do
          if authorised?('Pack material products', 'edit')
            show_page { PackMaterialApp::Config::MatresSubType::Config.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do
          response['Content-Type'] = 'application/json'
          config = PackMaterialApp::ConfigRepo.new.find_matres_config_for_sub_type(id)
          config_id = config.id
          res = interactor.update_matres_config(config_id, params[:matres_sub_type])
          if res.success
            flash[:notice] = res.message
            if fetch?(r)
              redirect_via_json_to_last_grid
            else
              redirect_to_last_grid(r)
            end
          else
            # TODO: test that this is working
            p "Did we get in here now? OUTSTANDING ROUTE TEST"
            content = show_page { PackMaterialApp::Config::MatresSubType::Config.call(id, params[:matres_sub_type], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
      end
      r.is do
        r.get do
          if authorised?('Pack material products', 'read')
            show_partial { PackMaterialApp::Config::MatresSubType::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do
          response['Content-Type'] = 'application/json'
          res = interactor.update_matres_sub_type(id, params[:matres_sub_type])
          if res.success
            update_grid_row(id, changes: { material_resource_type_id: res.instance[:material_resource_type_id], sub_type_name: res.instance[:sub_type_name] },
                            notice: res.message)
          else
            content = show_partial { PackMaterialApp::Config::MatresSubType::Edit.call(id, params[:matres_sub_type], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do
          response['Content-Type'] = 'application/json'
          res = interactor.delete_matres_sub_type(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'material_resource_sub_types' do
      interactor = PackMaterialApp::ConfigInteractor.new(current_user, {}, {}, {})
      r.on 'new' do
        if authorised?('Pack material products', 'new')
          show_partial_or_page(fetch?(r)) { PackMaterialApp::Config::MatresSubType::New.call(remote: fetch?(r)) }
        else
          fetch?(r) ? dialog_permission_error : show_unauthorised
        end
      end
      r.post do
        res = interactor.create_matres_sub_type(params[:matres_sub_type])
        if res.success
          flash[:notice] = res.message
          if fetch?(r)
            redirect_via_json_to_last_grid
          else
            redirect_to_last_grid(r)
          end
        elsif fetch?(r)
          content = show_partial do
            PackMaterialApp::Config::MatresSubType::New.call(form_values: params[:matres_sub_type],
                                                             form_errors: res.errors,
                                                             remote: true)
          end
          update_dialog_content(content: content, error: res.message)
        else
          flash[:error] = res.message
          show_page do
            PackMaterialApp::Config::MatresSubType::New.call(form_values: params[:matres_sub_type],
                                                             form_errors: res.errors,
                                                             remote: false)
          end
        end
      end
    end
    r.on 'link_product_columns', Integer do |id|
      r.post do
        interactor = PackMaterialApp::ConfigInteractor.new(current_user, {}, {}, {})
        res = interactor.link_product_columns(id, multiselect_grid_choices(params))
        if res.success
          flash[:notice] = res.message
        else
          flash[:error] = res.message
        end
        # TODO: Fix
        redirect_to_last_grid(r)
      end
    end
    # PACK MATERIAL PRODUCTS
    # --------------------------------------------------------------------------
    r.on 'pack_material_products', Integer do |id|
      interactor = PackMaterialApp::PmProductInteractor.new(current_user, {}, {}, {})

      # check for notfound
      r.on !interactor.exists?(:pack_material_products, id) do
        handle_not_found(r)
      end

      r.on 'edit' do
        if authorized?('Pack Material Products', 'edit')
          show_partial { PackMaterialApp::Config::PmProduct::Edit.call(id) }
        else
          dialog_permission_error
        end
      end
      r.is do
        r.get do
          if authorised?('Pack material products', 'read')
            show_partial { PackMaterialApp::Config::PmProduct::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do
          response['Content-Type'] = 'application/json'
          res = interactor.update_pm_product(id, params[:pm_product])
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
            content = show_partial { PackMaterialApp::Config::PmProduct::Edit.call(id, params[:pm_product], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do
          response['Content-Type'] = 'application/json'
          res = interactor.delete_pm_product(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'pack_material_products' do
      interactor = PackMaterialApp::PmProductInteractor.new(current_user, {}, {}, {})
      r.on 'new' do
        if authorised?('Pack Material Products', 'new')
          show_partial_or_page(fetch?(r)) { PackMaterialApp::Config::PmProduct::New.call(remote: fetch?(r)) }
        else
          fetch?(r) ? dialog_permission_error : show_unauthorised
        end
      end
      r.post do
        res = interactor.create_pm_product(params[:pm_product])
        if res.success
          flash[:notice] = res.message
          if fetch?(r)
            redirect_via_json_to_last_grid
          else
            redirect_to_last_grid(r)
          end
        elsif fetch?(r)
          content = show_partial do
            PackMaterialApp::Config::PmProduct::New.call(form_values: params[:pm_product],
                                                         form_errors: res.errors,
                                                         remote: true)
          end
          update_dialog_content(content: content, error: res.message)
        else
          flash[:error] = res.message
          show_page do
            PackMaterialApp::Config::PmProduct::New.call(form_values: params[:pm_product],
                                                         form_errors: res.errors,
                                                         remote: false)
          end
        end
      end
    end
  end
end
