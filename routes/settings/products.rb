# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/BlockLength

class Framework < Roda
  route 'products', 'settings' do |r|
    # PRODUCT TYPES
    # --------------------------------------------------------------------------
    r.on 'product_types', Integer do |id|
      interactor = ProductTypeInteractor.new(current_user, {}, {}, {})

      # Check for notfound:
      r.on !interactor.exists?(:product_types, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        if authorised?('products', 'edit')
          show_partial { Settings::Products::ProductType::Edit.call(id) }
        else
          dialog_permission_error
        end
      end
      r.is do
        r.get do       # SHOW
          if authorised?('products', 'read')
            show_partial { Settings::Products::ProductType::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          response['Content-Type'] = 'application/json'
          res = interactor.update_product_type(id, params[:product_type])
          if res.success
            update_grid_row(id, changes: { packing_material_product_type_id: res.instance[:packing_material_product_type_id], packing_material_product_sub_type_id: res.instance[:packing_material_product_sub_type_id], active: res.instance[:active] },
                            notice: res.message)
          else
            content = show_partial { Settings::Products::ProductType::Edit.call(id, params[:product_type], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          response['Content-Type'] = 'application/json'
          res = interactor.delete_product_type(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'product_types' do
      interactor = ProductTypeInteractor.new(current_user, {}, {}, {})
      r.on 'new' do    # NEW
        if authorised?('products', 'new')
          show_partial_or_page(fetch?(r)) { Settings::Products::ProductType::New.call(remote: fetch?(r)) }
        else
          fetch?(r) ? dialog_permission_error : show_unauthorised
        end
      end
      r.post do        # CREATE
        res = interactor.create_product_type(params[:product_type])
        if res.success
          flash[:notice] = res.message
          if fetch?(r)
            redirect_via_json_to_last_grid
          else
            redirect_to_last_grid(r)
          end
        elsif fetch?(r)
          content = show_partial do
            Settings::Products::ProductType::New.call(form_values: params[:product_type],
                                                      form_errors: res.errors,
                                                      remote: true)
          end
          update_dialog_content(content: content, error: res.message)
        else
          flash[:error] = res.message
          show_page do
            Settings::Products::ProductType::New.call(form_values: params[:product_type],
                                                      form_errors: res.errors,
                                                      remote: false)
          end
        end
      end
    end
    # PACKING MATERIAL PRODUCT TYPES
    # --------------------------------------------------------------------------
    r.on 'packing_material_product_types', Integer do |id|
      interactor = ProductTypeInteractor.new(current_user, {}, {}, {})

      # Check for notfound:
      r.on !interactor.exists?(:packing_material_product_types, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        if authorised?('products', 'edit')
          show_partial { Settings::Products::PackingMaterialProductType::Edit.call(id) }
        else
          dialog_permission_error
        end
      end
      r.is do
        r.get do       # SHOW
          if authorised?('products', 'read')
            show_partial { Settings::Products::PackingMaterialProductType::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          response['Content-Type'] = 'application/json'
          res = interactor.update_packing_material_product_type(id, params[:packing_material_product_type])
          if res.success
            update_grid_row(id, changes: { packing_material_type_name: res.instance[:packing_material_type_name] },
                            notice: res.message)
          else
            content = show_partial { Settings::Products::PackingMaterialProductType::Edit.call(id, params[:packing_material_product_type], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          response['Content-Type'] = 'application/json'
          res = interactor.delete_packing_material_product_type(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'packing_material_product_types' do
      interactor = ProductTypeInteractor.new(current_user, {}, {}, {})
      r.on 'new' do    # NEW
        if authorised?('products', 'new')
          show_partial_or_page(fetch?(r)) { Settings::Products::PackingMaterialProductType::New.call(remote: fetch?(r)) }
        else
          fetch?(r) ? dialog_permission_error : show_unauthorised
        end
      end
      r.post do        # CREATE
        res = interactor.create_packing_material_product_type(params[:packing_material_product_type])
        if res.success
          flash[:notice] = res.message
          if fetch?(r)
            redirect_via_json_to_last_grid
          else
            redirect_to_last_grid(r)
          end
        elsif fetch?(r)
          content = show_partial do
            Settings::Products::PackingMaterialProductType::New.call(form_values: params[:packing_material_product_type],
                                                                     form_errors: res.errors,
                                                                     remote: true)
          end
          update_dialog_content(content: content, error: res.message)
        else
          flash[:error] = res.message
          show_page do
            Settings::Products::PackingMaterialProductType::New.call(form_values: params[:packing_material_product_type],
                                                                     form_errors: res.errors,
                                                                     remote: false)
          end
        end
      end
    end
    # PACKING MATERIAL PRODUCT SUB TYPES
    # --------------------------------------------------------------------------
    r.on 'packing_material_product_sub_types', Integer do |id|
      interactor = ProductTypeInteractor.new(current_user, {}, {}, {})

      # Check for notfound:
      r.on !interactor.exists?(:packing_material_product_sub_types, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        if authorised?('products', 'edit')
          show_partial { Settings::Products::PackingMaterialProductSubType::Edit.call(id) }
        else
          dialog_permission_error
        end
      end
      r.is do
        r.get do       # SHOW
          if authorised?('products', 'read')
            show_partial { Settings::Products::PackingMaterialProductSubType::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          response['Content-Type'] = 'application/json'
          res = interactor.update_packing_material_product_sub_type(id, params[:packing_material_product_sub_type])
          if res.success
            update_grid_row(id, changes: { packing_material_product_type_id: res.instance[:packing_material_product_type_id], packing_material_sub_type_name: res.instance[:packing_material_sub_type_name] },
                            notice: res.message)
          else
            content = show_partial { Settings::Products::PackingMaterialProductSubType::Edit.call(id, params[:packing_material_product_sub_type], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          response['Content-Type'] = 'application/json'
          res = interactor.delete_packing_material_product_sub_type(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'packing_material_product_sub_types' do
      interactor = ProductTypeInteractor.new(current_user, {}, {}, {})
      r.on 'new' do    # NEW
        if authorised?('products', 'new')
          show_partial_or_page(fetch?(r)) { Settings::Products::PackingMaterialProductSubType::New.call(remote: fetch?(r)) }
        else
          fetch?(r) ? dialog_permission_error : show_unauthorised
        end
      end
      r.post do        # CREATE
        res = interactor.create_packing_material_product_sub_type(params[:packing_material_product_sub_type])
        if res.success
          flash[:notice] = res.message
          if fetch?(r)
            redirect_via_json_to_last_grid
          else
            redirect_to_last_grid(r)
          end
        elsif fetch?(r)
          content = show_partial do
            Settings::Products::PackingMaterialProductSubType::New.call(form_values: params[:packing_material_product_sub_type],
                                                                        form_errors: res.errors,
                                                                        remote: true)
          end
          update_dialog_content(content: content, error: res.message)
        else
          flash[:error] = res.message
          show_page do
            Settings::Products::PackingMaterialProductSubType::New.call(form_values: params[:packing_material_product_sub_type],
                                                                        form_errors: res.errors,
                                                                        remote: false)
          end
        end
      end
    end
    # PRODUCTS
    # --------------------------------------------------------------------------
    r.on 'products', Integer do |id|
      interactor = ProductTypeInteractor.new(current_user, {}, {}, {})
      # interactor = ProductInteractor.new(current_user, {}, {}, {})

      # Check for notfound:
      r.on !interactor.exists?(:products, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        if authorised?('products', 'edit')
          show_partial { Settings::Products::Product::Edit.call(id) }
        else
          dialog_permission_error
        end
      end
      r.is do
        r.get do       # SHOW
          if authorised?('products', 'read')
            show_partial { Settings::Products::Product::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          response['Content-Type'] = 'application/json'
          res = interactor.update_product(id, params[:product])
          if res.success
            update_grid_row(id, changes: { product_type_id: res.instance[:product_type_id], variant: res.instance[:variant], style: res.instance[:style], assembly_type: res.instance[:assembly_type], market_major: res.instance[:market_major], commodity: res.instance[:commodity], variety: res.instance[:variety], ctn_size_basic: res.instance[:ctn_size_basic], ctn_size_old_pack: res.instance[:ctn_size_old_pack], pls_pack_code: res.instance[:pls_pack_code], fruit_mass_nett_kg: res.instance[:fruit_mass_nett_kg], holes: res.instance[:holes], perforation: res.instance[:perforation], image: res.instance[:image], length_mm: res.instance[:length_mm], width_mm: res.instance[:width_mm], height_mm: res.instance[:height_mm], diameter_mm: res.instance[:diameter_mm], thick_mm: res.instance[:thick_mm], thick_mic: res.instance[:thick_mic], colour: res.instance[:colour], grade: res.instance[:grade], mass: res.instance[:mass], material_type: res.instance[:material_type], treatment: res.instance[:treatment], specification_notes: res.instance[:specification_notes], artwork_commodity: res.instance[:artwork_commodity], artwork_marketing_variety_group: res.instance[:artwork_marketing_variety_group], artwork_variety: res.instance[:artwork_variety], artwork_nett_mass: res.instance[:artwork_nett_mass], artwork_brand: res.instance[:artwork_brand], artwork_class: res.instance[:artwork_class], artwork_plu_number: res.instance[:artwork_plu_number], artwork_other: res.instance[:artwork_other], artwork_image: res.instance[:artwork_image], marketer: res.instance[:marketer], retailer: res.instance[:retailer], supplier: res.instance[:supplier], supplier_stock_code: res.instance[:supplier_stock_code], product_alternative: res.instance[:product_alternative], product_joint_use: res.instance[:product_joint_use], ownership: res.instance[:ownership], consignment_stock: res.instance[:consignment_stock], start_date: res.instance[:start_date], end_date: res.instance[:end_date], active: res.instance[:active], remarks: res.instance[:remarks] },
                            notice: res.message)
          else
            content = show_partial { Settings::Products::Product::Edit.call(id, params[:product], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          response['Content-Type'] = 'application/json'
          res = interactor.delete_product(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'products' do
      interactor = ProductTypeInteractor.new(current_user, {}, {}, {})
      # interactor = ProductInteractor.new(current_user, {}, {}, {})
      r.on 'new' do    # NEW
        if authorised?('products', 'new')
          show_partial_or_page(fetch?(r)) { Settings::Products::Product::New.call(remote: fetch?(r)) }
        else
          fetch?(r) ? dialog_permission_error : show_unauthorised
        end
      end
      r.post do        # CREATE
        res = interactor.create_product(params[:product])
        if res.success
          flash[:notice] = res.message
          if fetch?(r)
            redirect_via_json_to_last_grid
          else
            redirect_to_last_grid(r)
          end
        elsif fetch?(r)
          content = show_partial do
            Settings::Products::Product::New.call(form_values: params[:product],
                                                  form_errors: res.errors,
                                                  remote: true)
          end
          update_dialog_content(content: content, error: res.message)
        else
          flash[:error] = res.message
          show_page do
            Settings::Products::Product::New.call(form_values: params[:product],
                                                  form_errors: res.errors,
                                                  remote: false)
          end
        end
      end
    end
    r.on 'link_product_column_names', Integer do |id|
      r.post do
        interactor = ProductTypeInteractor.new(current_user, {}, {}, {})
        res = interactor.link_product_column_names(id, multiselect_grid_choices(params))
        if res.success
          flash[:notice] = res.message
        else
          flash[:error] = res.message
        end
        redirect_via_json_to_last_grid
      end
    end
    r.on 'link_product_code_column_names', Integer do |id|
      r.post do
        interactor = ProductTypeInteractor.new(current_user, {}, {}, {})

        res = interactor.link_product_code_column_names(id, multiselect_grid_choices(params))
        if res.success
          flash[:notice] = res.message
        else
          flash[:error] = res.message
        end
        redirect_via_json_to_last_grid
      end
    end

    r.on 'reorder_product_code_column_names', Integer do |id|
      r.get do
        show_partial { Settings::Products::ProductType::SortProductCodeColumnNames.call(id) }
      end
      r.post do
        interactor = ProductTypeInteractor.new(current_user, {}, {}, {})

        res = interactor.reorder_product_code_column_names(id, params[:columncodes_sorted_ids])
        if res.success
          flash[:notice] = res.message
        else
          flash[:error] = res.message
        end
        redirect_via_json_to_last_grid
      end
    end
  end
end
