# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/BlockLength

class Framework < Roda
  route 'dispatch', 'pack_material' do |r|
    # GOODS RETURNED NOTES
    # --------------------------------------------------------------------------
    r.on 'mr_goods_returned_notes', Integer do |id|
      interactor = PackMaterialApp::MrGoodsReturnedNoteInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:mr_goods_returned_notes, id) do
        handle_not_found(r)
      end

      r.on 'complete_invoice' do
        check_auth!('dispatch', 'edit')
        store_last_referer_url(:grn_complete_invoice)
        res = interactor.complete_invoice(id)
        if res.success
          flash[:notice] = res.message
        else
          flash[:error] = res.message
        end
        redirect_to_stored_referer(r, :grn_complete_invoice)
      end
      r.on 'edit' do   # EDIT
        check_auth!('dispatch', 'edit')
        interactor.assert_permission!(:edit, id)
        show_page { PackMaterial::Dispatch::MrGoodsReturnedNote::Edit.call(id, current_user, interactor: interactor) }
      end

      r.on 'ship_goods' do
        check_auth!('dispatch', 'edit')
        res = interactor.ship_mr_goods_returned_note(id)
        if res.success
          flash[:notice] = res.message
        else
          flash[:error] = res.message
        end
        r.redirect("/pack_material/dispatch/mr_goods_returned_notes/#{id}/edit")
      end

      r.on 'mr_goods_returned_note_items' do
        item_interactor = PackMaterialApp::MrGoodsReturnedNoteItemInteractor.new(current_user, {}, { route_url: request.path }, {})
        r.on 'new' do    # NEW
          check_auth!('dispatch', 'new')
          show_partial_or_page(r) { PackMaterial::Dispatch::MrGoodsReturnedNoteItem::New.call(id, remote: fetch?(r)) }
        end
        r.post do        # CREATE
          res = item_interactor.create_mr_goods_returned_note_item(id, params[:mr_goods_returned_note_item])
          if res.success
            row_keys = %i[
              id
              mr_goods_returned_note_id
              mr_delivery_item_id
              mr_delivery_item_batch_id
              remarks
              quantity_returned
              status
              product_variant_code
              product_variant_number
              sku_number
            ]
            add_grid_row(attrs: select_attributes(res.instance, row_keys), notice: res.message)
          else
            re_show_form(r, res, url: "/pack_material/dispatch/mr_goods_returned_notes/#{id}/mr_goods_returned_note_items/new") do
              PackMaterial::Dispatch::MrGoodsReturnedNoteItem::New.call(id,
                                                                        form_values: params[:mr_goods_returned_note_item],
                                                                        form_errors: res.errors,
                                                                        remote: fetch?(r))
            end
          end
        end
      end

      r.is do
        r.get do       # SHOW
          check_auth!('dispatch', 'read')
          show_partial { PackMaterial::Dispatch::MrGoodsReturnedNote::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_mr_goods_returned_note(id, params[:mr_goods_returned_note])
          if res.success
            flash[:notice] = res.message
            r.redirect("/pack_material/dispatch/mr_goods_returned_notes/#{id}/edit")
          else
            re_show_form(r, res, url: "/pack_material/dispatch/mr_goods_returned_notes/#{id}/edit") do
              PackMaterial::Dispatch::MrGoodsReturnedNote::Edit.call(id, current_user, form_values: params[:mr_goods_returned_note], form_errors: res.errors, interactor: interactor)
            end
          end
        end
        r.delete do    # DELETE
          check_auth!('dispatch', 'delete')
          interactor.assert_permission!(:delete, id)
          res = interactor.delete_mr_goods_returned_note(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end

    r.on 'mr_goods_returned_notes' do
      interactor = PackMaterialApp::MrGoodsReturnedNoteInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do    # NEW
        check_auth!('dispatch', 'new')
        set_last_grid_url('/list/mr_goods_returned_notes/with_params?key=unshipped', r)
        show_partial_or_page(r) { PackMaterial::Dispatch::MrGoodsReturnedNote::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_mr_goods_returned_note(params[:mr_goods_returned_note])
        if res.success
          if fetch?(r)
            row_keys = %i[
              id
              mr_delivery_id
              delivery_number
              credit_note_number
              issue_transaction_id
              dispatch_location_id
              created_by
              shipped
              remarks
              status
            ]
            add_grid_row(attrs: select_attributes(res.instance, row_keys),
                         notice: res.message)
          else
            flash[:notice] = res.message
            redirect_to_last_grid(r)
          end
        else
          re_show_form(r, res, url: '/pack_material/dispatch/mr_goods_returned_notes/new') do
            PackMaterial::Dispatch::MrGoodsReturnedNote::New.call(form_values: params[:mr_goods_returned_note],
                                                                  form_errors: res.errors,
                                                                  remote: fetch?(r))
          end
        end
      end
    end

    # MR GOODS RETURNED NOTE ITEMS
    # --------------------------------------------------------------------------
    r.on 'mr_goods_returned_note_items', Integer do |id|
      interactor = PackMaterialApp::MrGoodsReturnedNoteItemInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:mr_goods_returned_note_items, id) do
        handle_not_found(r)
      end

      r.on 'inline_save' do
        check_auth!('transactions', 'edit')
        res = interactor.inline_update(id, params)
        if res.success
          parent_id = interactor.mr_goods_returned_note_item(id)&.mr_goods_returned_note_id
          permission_res = interactor.can_ship(parent_id)
          if permission_res.success
            json_actions([OpenStruct.new(type: :show_element, dom_id: 'mr_goods_returned_notes_ship_button')], res.message)
          else
            json_actions([OpenStruct.new(type: :hide_element, dom_id: 'mr_goods_returned_notes_ship_button')], res.message)
          end
        else
          show_json_error(res.message, status: 200)
        end
      end
      r.is do
        r.patch do     # UPDATE
          res = interactor.update_mr_goods_returned_note_item(id, params[:mr_goods_returned_note_item])
          if res.success
            row_keys = %i[
              mr_goods_returned_note_id
              mr_delivery_item_id
              mr_delivery_item_batch_id
              remarks
              quantity_returned
              status
              product_variant_code
              product_variant_number
              sku_number
            ]
            update_grid_row(id, changes: select_attributes(res.instance, row_keys), notice: res.message)
          else
            re_show_form(r, res) { PackMaterial::Dispatch::MrGoodsReturnedNoteItem::Edit.call(id, form_values: params[:mr_goods_returned_note_item], form_errors: res.errors, interactor: interactor) }
          end
        end
        r.delete do    # DELETE
          check_auth!('dispatch', 'delete')
          interactor.assert_permission!(:delete, id)
          res = interactor.delete_mr_goods_returned_note_item(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/BlockLength
