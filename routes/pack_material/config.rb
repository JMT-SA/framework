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
          check_auth!('config', 'new')
          show_partial_or_page(r) { PackMaterial::Config::MatresType::Unit.call(id, remote: fetch?(r)) }
        end
        r.post do        # CREATE
          res = interactor.add_a_matres_unit(id, params[:matres_type])
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
        check_auth!('config', 'edit')
        show_partial { PackMaterial::Config::MatresType::Edit.call(id) }
      end
      r.is do
        r.get do
          check_auth!('config', 'read')
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
          check_auth!('config', 'delete')
          res = interactor.delete_matres_type(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end

    r.on 'material_resource_types' do
      interactor = PackMaterialApp::ConfigInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do
        check_auth!('config', 'new')
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
        check_auth!('config', 'edit')
        show_partial { PackMaterial::Config::MatresSubType::Edit.call(id) }
      end
      r.on 'product_columns' do
        check_auth!('config', 'edit')
        repo = PackMaterialApp::ConfigRepo.new
        product_column_ids = repo.find_matres_sub_type(id).product_column_ids || []
        if product_column_ids.any?
          r.redirect "/list/material_resource_product_column_master_list_items/with_params?key=standard&sub_type_id=#{id}&product_column_ids=#{product_column_ids}"
        else
          flash[:error] = 'No product columns selected, please see config.'
          r.redirect '/list/material_resource_sub_types'
        end
      end
      r.on 'material_resource_master_list_items', Integer do |item_id|
        r.on 'edit' do
          check_auth!('config', 'edit')
          show_partial { PackMaterial::Config::MatresMasterListItem::Edit.call(item_id) }
        end
        r.patch do     # UPDATE
          return_json_response
          res = interactor.update_matres_master_list_item(item_id, params[:matres_master_list_item])
          if res.success
            row_keys = %i[
              material_resource_master_list_id
              short_code
              long_name
              description
              active
            ]
            update_grid_row(item_id, changes: select_attributes(res.instance, row_keys), notice: res.message)
          else
            content = show_partial { PackMaterial::Config::MatresMasterListItem::Edit.call(item_id, params[:matres_master_list_item], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
      end
      r.on 'material_resource_master_list_items' do
        r.on 'preselect' do
          check_auth!('config', 'new')
          show_partial_or_page(r) { PackMaterial::Config::MatresMasterListItem::Preselect.call(id) }
        end
        r.on 'new', Integer do |product_column_id|
          check_auth!('config', 'new')
          show_partial_or_page(r) { PackMaterial::Config::MatresMasterListItem::New.call(id, product_column_id, fetch?(r)) }
        end
        r.on 'new' do
          r.post do
            return_json_response
            check_auth!('config', 'new')
            product_column_id = params[:matres_master_list_item][:material_resource_product_column_id].to_i

            re_show_form(r, OpenStruct.new(message: nil), url: "/pack_material/config/material_resource_sub_types/#{id}/material_resource_master_list_items/new/#{product_column_id}") do
              PackMaterial::Config::MatresMasterListItem::New.call(id, product_column_id)
            end
          end
        end
        r.post do        # CREATE
          res = interactor.create_matres_master_list_item(id, params[:matres_master_list_item])
          product_column_id = params[:matres_master_list_item][:material_resource_product_column_id]
          if res.success
            repo = PackMaterialApp::ConfigRepo.new
            items = repo.matres_sub_type_master_list_items(id, product_column_id)
            items = items.map { |r| "#{r[:short_code]} #{r[:long_name] ? '- ' + r[:long_name] : ''}" }
            json_actions([
                           OpenStruct.new(type: :replace_input_value, dom_id: 'matres_master_list_item_short_code', value: ''),
                           OpenStruct.new(type: :replace_input_value, dom_id: 'matres_master_list_item_long_name', value: ''),
                           OpenStruct.new(type: :replace_input_value, dom_id: 'matres_master_list_item_description', value: ''),
                           OpenStruct.new(type: :replace_list_items, dom_id: 'matres_master_list_item_list_items', items: items)
                         ],
                         'Added new item',
                         keep_dialog_open: true)
          else
            re_show_form(r, res, url: "/pack_material/config/material_resource_sub_types/#{id}/material_resource_master_lists/new") do
              PackMaterial::Config::MatresMasterListItem::New.call(id, product_column_id, form_values: params[:matres_master_list_item],
                                                                   form_errors: res.errors,
                                                                   remote: fetch?(r))
            end
          end
        end
      end
      r.on 'config' do
        r.is 'edit' do
          check_auth!('config', 'edit')
          show_partial_or_page(r) { PackMaterial::Config::MatresSubType::Config.call(id) }
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
          check_auth!('config', 'read')
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
          check_auth!('config', 'delete')
          res = interactor.delete_matres_sub_type(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            flash[:error] = res.message
            redirect_to_last_grid(r)
          end
        end
      end
    end
    r.on 'material_resource_sub_types' do
      interactor = PackMaterialApp::ConfigInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do
        check_auth!('config', 'new')
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
      r.on 'pack_material_product_variants' do
        r.on 'new' do    # NEW
          check_auth!('config', 'new')
          show_partial_or_page(r) { PackMaterial::Config::PmProductVariant::New.call(id, remote: fetch?(r)) }
        end
        r.on 'clone', Integer do |variant_id|
          r.post do
            res = interactor.clone_pm_product_variant(id, params[:pm_product_variant])
            if res.success
              flash[:notice] = res.message
              redirect_to_last_grid(r)
            else
              re_show_form(r, res, url: "/pack_material/config/pack_material_product_variants/clone/#{variant_id}") do
                PackMaterial::Config::PmProductVariant::Clone.call(variant_id, params[:pm_product_variant], res.errors)
              end
            end
          end
        end
        r.post do        # CREATE
          return_json_response
          res = interactor.create_pm_product_variant(id, params[:pm_product_variant])
          if res.success
            flash[:notice] = res.message
            redirect_via_json('/list/pack_material_product_variants')
          else
            re_show_form(r, res, url: "/pack_material/config/pack_material_products/#{id}/pack_material_product_variants/new") do
              PackMaterial::Config::PmProductVariant::New.call(id,
                                                               form_values: params[:pm_product_variant],
                                                               form_errors: res.errors,
                                                               remote: fetch?(r))
            end
          end
        end
      end
      r.on 'edit' do
        check_auth!('config', 'edit')
        show_partial { PackMaterial::Config::PmProduct::Edit.call(id) }
      end
      r.on 'clone' do
        check_auth!('config', 'new')
        show_partial_or_page(r) { PackMaterial::Config::PmProduct::Clone.call(id) }
      end
      r.is do
        r.get do
          check_auth!('config', 'read')
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
              grade
              language
              market
              marking
              material
              material_resource_sub_type_id
              model
              other
              pm_class
              product_code
              product_number
              reference_dimension
              reference_mass
              reference_number
              reference_quantity
              reference_size
              shape
              style
              unit
              marketing_variety_id
            ]
            update_grid_row(id, changes: select_attributes(res.instance, row_keys), notice: res.message)
          else
            content = show_partial { PackMaterial::Config::PmProduct::Edit.call(id, params[:pm_product], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do
          return_json_response
          check_auth!('config', 'delete')
          res = interactor.delete_pm_product(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            flash[:error] = res.message
            redirect_to_last_grid(r)
          end
        end
      end
    end
    r.on 'pack_material_products' do
      interactor = PackMaterialApp::PmProductInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'preselect' do
        check_auth!('config', 'new')
        show_partial_or_page(r) { PackMaterial::Config::PmProduct::Preselect.call(remote: fetch?(r)) }
      end
      r.on 'new', Integer do |sub_type_id|
        check_auth!('config', 'new')
        show_partial_or_page(r) { PackMaterial::Config::PmProduct::New.call(sub_type_id: sub_type_id, remote: fetch?(r)) }
      end
      r.on 'new' do
        r.post do
          return_json_response
          check_auth!('config', 'new')
          sub_type_id = params[:pm_product][:material_resource_sub_type_id].to_i

          re_show_form(r, OpenStruct.new(message: nil), url: "/pack_material/config/pack_material_products/new/#{sub_type_id}") do
            PackMaterial::Config::PmProduct::New.call(sub_type_id)
          end
        end
      end
      r.on 'clone', Integer do |id|
        r.post do        # CLONE
          res = interactor.clone_pm_product(params[:pm_product])
          if res.success
            flash[:notice] = res.message
            redirect_to_last_grid(r)
          else
            re_show_form(r, res, url: "/pack_material/config/pack_material_products/#{id}/clone") do
              PackMaterial::Config::PmProduct::Clone.call(id, params[:pm_product], res.errors)
            end
          end
        end
      end
      r.post do        # CREATE
        res = interactor.create_pm_product(params[:pm_product])
        if res.success
          flash[:notice] = res.message
          redirect_to_last_grid(r)
        else
          sub_type_id = params[:pm_product][:material_resource_sub_type_id].to_i
          re_show_form(r, res, url: "/pack_material/config/pack_material_products/new/#{sub_type_id}") do
            PackMaterial::Config::PmProduct::New.call(sub_type_id, params[:pm_product], res.errors)
          end
        end
      end
    end
    # PACK MATERIAL PRODUCT VARIANTS
    # --------------------------------------------------------------------------
    r.on 'pack_material_product_variants', Integer do |id|
      interactor = PackMaterialApp::PmProductInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:pack_material_product_variants, id) do
        handle_not_found(r)
      end
      r.on 'edit' do   # EDIT
        check_auth!('config', 'edit')
        show_partial { PackMaterial::Config::PmProductVariant::Edit.call(id) }
      end
      r.on 'clone' do    # CLONE
        check_auth!('config', 'new')
        show_partial_or_page(r) { PackMaterial::Config::PmProductVariant::Clone.call(id) }
      end
      r.is do
        r.get do       # SHOW
          check_auth!('config', 'read')
          show_partial { PackMaterial::Config::PmProductVariant::Show.call(id) }
        end
        r.patch do     # UPDATE
          return_json_response
          res = interactor.update_pm_product_variant(id, params[:pm_product_variant])
          if res.success
            row_keys = %i[
              pack_material_product_id
              product_variant_number
              unit
              style
              alternate
              shape
              reference_size
              reference_dimension
              reference_quantity
              brand_1
              brand_2
              colour
              material
              assembly
              reference_mass
              reference_number
              market
              marking
              model
              pm_class
              grade
              language
              other
            ]
            update_grid_row(id, changes: select_attributes(res.instance, row_keys), notice: res.message)
          else
            content = show_partial { PackMaterial::Config::PmProductVariant::Edit.call(id, params[:pm_product_variant], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          return_json_response
          check_auth!('config', 'delete')
          res = interactor.delete_pm_product_variant(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/BlockLength
