# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/BlockLength

class Framework < Roda
  route 'config', 'pack_material' do |r|
    # MATERIAL RESOURCE TYPES
    # --------------------------------------------------------------------------
    r.on 'material_resource_types', Integer do |id|
      interactor = PackMaterialApp::ConfigInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:material_resource_types, id) do
        handle_not_found(r)
      end

      r.on 'unit' do
        r.on 'new' do    # NEW
          raise Crossbeams::AuthorizationError unless authorised?('config', 'new')
          show_partial_or_page(r) { PackMaterial::Config::MatresType::Unit.call(id, remote: fetch?(r)) }
        end
        r.post do        # CREATE
          if params[:matres_type] && params[:matres_type][:unit_of_measure] == 'other'
            res = interactor.create_matres_unit(id, params[:matres_type])
          else
            res = interactor.add_matres_unit(id, params[:matres_type])
          end

          if res.success
            flash[:notice] = res.message
            redirect_to_last_grid(r)
          else
            re_show_form(r, res, url: "/pack_material/config/material_resource_types/#{id}/unit/new") do
              PackMaterial::Config::MatresType::Unit.call(id,
                                                          form_values: params[:matres_type],
                                                          form_errors: res.errors,
                                                          remote: fetch?(r))
            end
          end
        end
      end
      r.on 'edit' do
        raise Crossbeams::AuthorizationError unless authorised?('config', 'edit')
        show_partial { PackMaterial::Config::MatresType::Edit.call(id) }
      end
      r.is do
        r.get do
          raise Crossbeams::AuthorizationError unless authorised?('config', 'read')
          show_partial { PackMaterial::Config::MatresType::Show.call(id) }
        end
        r.patch do
          return_json_response
          res = interactor.update_matres_type(id, params[:matres_type])
          if res.success
            update_grid_row(id, changes: { material_resource_domain_id: res.instance[:material_resource_domain_id],
                                           type_name: res.instance[:type_name],
                                           short_code: res.instance[:short_code],
                                           description: res.instance[:description] },
                                notice: res.message)
          else
            content = show_partial { PackMaterial::Config::MatresType::Edit.call(id, params[:matres_type], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do
          return_json_response
          raise Crossbeams::AuthorizationError unless authorised?('config', 'delete')
          res = interactor.delete_matres_type(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end

    r.on 'material_resource_types' do
      interactor = PackMaterialApp::ConfigInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do
        raise Crossbeams::AuthorizationError unless authorised?('config', 'new')
        show_partial_or_page(r) { PackMaterial::Config::MatresType::New.call(remote: fetch?(r)) }
      end
      r.post do
        res = interactor.create_matres_type(params[:matres_type])
        if res.success
          flash[:notice] = res.message
          redirect_to_last_grid(r)
        else
          re_show_form(r, res, url: '/pack_material/config/material_resource_types/new') do
            PackMaterial::Config::MatresType::New.call(form_values: params[:matres_type],
                                                       form_errors: res.errors,
                                                       remote: fetch?(r))
          end
        end
      end
    end

    # MATERIAL RESOURCE SUB TYPES
    # --------------------------------------------------------------------------
    r.on 'material_resource_sub_types', Integer do |id|
      interactor = PackMaterialApp::ConfigInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:material_resource_sub_types, id) do
        handle_not_found(r)
      end

      r.on 'edit' do
        raise Crossbeams::AuthorizationError unless authorised?('config', 'edit')
        show_partial { PackMaterial::Config::MatresSubType::Edit.call(id) }
      end
      r.on 'product_columns' do
        raise Crossbeams::AuthorizationError unless authorised?('config', 'read')
        repo = PackMaterialApp::ConfigRepo.new()
        product_column_ids = repo.find_matres_sub_type(id).product_column_ids || []
        if product_column_ids.any?
          r.redirect "/list/material_resource_product_columns/with_params?key=standard&product_column_ids=#{product_column_ids}"
        else
          flash[:error] = "No product columns selected, please see config."
          r.redirect "/list/material_resource_sub_types"
        end
      end
      r.on 'config' do
        r.is 'edit' do
          raise Crossbeams::AuthorizationError unless authorised?('config', 'edit')
          page = stashed_page
          if page
            show_page { page }
          else
            show_page { PackMaterial::Config::MatresSubType::Config.call(id) }
          end
        end
        r.patch do
          return_json_response
          res = interactor.update_matres_config(id, params[:matres_sub_type])
          if res.success
            show_json_notice(res.message)
          else
            show_json_error(res.message)
          end
        end
      end

      r.on 'update_product_code_configuration' do
        r.post do
          res = interactor.update_product_code_configuration(id, params[:product_code_columns])
          if res.success
            flash[:notice] = res.message
            redirect_to_last_grid(r)
          else
            flash[:error] = res.message
            stash_page(PackMaterial::Config::MatresSubType::Config.call(id, form_values: params[:product_code_columns],
                                                                            form_errors: res.errors))
            r.redirect "/pack_material/config/material_resource_sub_types/#{id}/config/edit"
          end
        end
      end

      r.is do
        r.get do
          raise Crossbeams::AuthorizationError unless authorised?('config', 'read')
          show_partial { PackMaterial::Config::MatresSubType::Show.call(id) }
        end
        r.patch do
          return_json_response
          res = interactor.update_matres_sub_type(id, params[:matres_sub_type])
          if res.success
            update_grid_row(id, changes: {  material_resource_type_id: res.instance[:material_resource_type_id],
                                            sub_type_name: res.instance[:sub_type_name],
                                            short_code: res.instance[:short_code],
                                            product_code_separator: res.instance[:product_code_separator],
                                            has_suppliers: res.instance[:has_suppliers],
                                            has_marketers: res.instance[:has_marketers],
                                            has_retailers: res.instance[:has_retailers],
                                            product_column_ids: res.instance[:product_column_ids],
                                            product_code_ids: res.instance[:product_code_ids] },
                                notice: res.message)
          else
            content = show_partial { PackMaterial::Config::MatresSubType::Edit.call(id, params[:matres_sub_type], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do
          return_json_response
          raise Crossbeams::AuthorizationError unless authorised?('config', 'delete')
          res = interactor.delete_matres_sub_type(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end

    r.on 'material_resource_sub_types' do
      interactor = PackMaterialApp::ConfigInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do
        raise Crossbeams::AuthorizationError unless authorised?('config', 'new')
        show_partial_or_page(r) { PackMaterial::Config::MatresSubType::New.call(remote: fetch?(r)) }
      end
      r.post do
        res = interactor.create_matres_sub_type(params[:matres_sub_type])
        if res.success
          flash[:notice] = res.message
          redirect_to_last_grid(r)
        else
          re_show_form(r, res, url: '/pack_material/config/material_resource_sub_types/new') do
            PackMaterial::Config::MatresSubType::New.call(form_values: params[:matres_sub_type],
                                                          form_errors: res.errors,
                                                          remote: fetch?(r))
          end
        end
      end
    end

    r.on 'link_product_columns' do
      r.post do
        interactor = PackMaterialApp::ConfigInteractor.new(current_user, {}, { route_url: request.path }, {})
        ids = multiselect_grid_choices(params)
        res = interactor.chosen_product_columns(ids)
        json_actions([OpenStruct.new(type: :replace_multi_options, dom_id: 'product_code_columns_product_code_column_ids', options_array: res.instance[:code]),
                      OpenStruct.new(type: :replace_input_value, dom_id: 'product_code_columns_chosen_column_ids', value: ids.join(','))],
                     'Re-assigned product columns')
      end
    end
    # PACK MATERIAL PRODUCTS
    # --------------------------------------------------------------------------
    r.on 'pack_material_products', Integer do |id|
      interactor = PackMaterialApp::PmProductInteractor.new(current_user, {}, { route_url: request.path }, {})

      # check for notfound
      r.on !interactor.exists?(:pack_material_products, id) do
        handle_not_found(r)
      end

      r.on 'edit' do
        raise Crossbeams::AuthorizationError unless authorised?('config', 'edit')
        show_partial { PackMaterial::Config::PmProduct::Edit.call(id) }
      end
      r.is do
        r.get do
          raise Crossbeams::AuthorizationError unless authorised?('config', 'read')
          show_partial { PackMaterial::Config::PmProduct::Show.call(id) }
        end
        r.patch do     # UPDATE
          return_json_response
          res = interactor.update_pm_product(id, params[:pm_product])
          if res.success
            row_keys = %i[
              alternate
              assembly
              brand_1
              brand_2
              colour
              commodity_id
              diameter_mm
              grade
              height_mm
              language
              length_mm
              market
              marking
              material
              material_resource_sub_type_id
              model
              other
              pm_class
              product_code
              product_number
              reference_mass
              reference_number
              reference_quantity
              reference_size
              shape
              specification_notes
              style
              thick_mic
              thick_mm
              unit
              variety_id
              width_mm
            ]
            update_grid_row(id, changes: select_attributes(res.instance, row_keys, other: 'SOME override CHANGE'), notice: res.message)
          else
            content = show_partial { PackMaterial::Config::PmProduct::Edit.call(id, params[:pm_product], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do
          return_json_response
          raise Crossbeams::AuthorizationError unless authorised?('config', 'delete')
          res = interactor.delete_pm_product(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'pack_material_products' do
      interactor = PackMaterialApp::PmProductInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do
        raise Crossbeams::AuthorizationError unless authorised?('config', 'new')
        show_partial_or_page(r) { PackMaterial::Config::PmProduct::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_pm_product(params[:pm_product])
        if res.success
          flash[:notice] = res.message
          redirect_to_last_grid(r)
        else
          re_show_form(r, res, url: '/pack_material/config/pack_material_products/new') do
            PackMaterial::Config::PmProduct::New.call(form_values: params[:pm_product],
                                                      form_errors: res.errors,
                                                      remote: fetch?(r))
          end
        end
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/BlockLength
