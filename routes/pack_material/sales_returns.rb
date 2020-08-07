# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/BlockLength

class Framework < Roda
  route 'sales_returns', 'pack_material' do |r|
    # MR SALES RETURNS
    # --------------------------------------------------------------------------
    r.on 'mr_sales_returns', Integer do |id|
      interactor = PackMaterialApp::MrSalesReturnInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})

      # Check for notfound:
      r.on !interactor.exists?(:mr_sales_returns, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('dispatch', 'edit')
        interactor.assert_permission!(:edit, id)
        show_partial { PackMaterial::Dispatch::MrSalesReturn::Edit.call(id) }
      end

      r.is do
        r.get do       # SHOW
          check_auth!('dispatch', 'read')
          show_partial { PackMaterial::Dispatch::MrSalesReturn::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_mr_sales_return(id, params[:mr_sales_return])
          if res.success
            row_keys = %i[
              mr_sales_order_id
              issue_transaction_id
              created_by
              remarks
              sales_return_number
            ]
            update_grid_row(id, changes: select_attributes(res.instance, row_keys), notice: res.message)
          else
            re_show_form(r, res) { PackMaterial::Dispatch::MrSalesReturn::Edit.call(id, form_values: params[:mr_sales_return], form_errors: res.errors) }
          end
        end
        r.delete do    # DELETE
          check_auth!('dispatch', 'delete')
          interactor.assert_permission!(:delete, id)
          res = interactor.delete_mr_sales_return(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end

    r.on 'mr_sales_returns' do
      interactor = PackMaterialApp::MrSalesReturnInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})
      r.on 'new' do    # NEW
        check_auth!('dispatch', 'new')
        set_last_grid_url('/list/mr_sales_returns', r)
        show_partial_or_page(r) { PackMaterial::Dispatch::MrSalesReturn::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_mr_sales_return(params[:mr_sales_return])
        if res.success
          if fetch?(r)
            row_keys = %i[
              id
              mr_sales_order_id
              issue_transaction_id
              created_by
              remarks
              sales_return_number
            ]
            add_grid_row(attrs: select_attributes(res.instance, row_keys),
                         notice: res.message)
          else
            flash[:notice] = res.message
            redirect_to_last_grid(r)
          end
        else
          re_show_form(r, res, url: '/pack_material/dispatch/mr_sales_returns/new') do
            PackMaterial::Dispatch::MrSalesReturn::New.call(form_values: params[:mr_sales_return],
                                                            form_errors: res.errors,
                                                            remote: fetch?(r))
          end
        end
      end
    end
  end

  def sr_sub_total_changes(sub_totals)
    [
      OpenStruct.new(dom_id: 'sr_totals_subtotal', type: :replace_inner_html, value: sub_totals[:subtotal]),
      OpenStruct.new(dom_id: 'sr_totals_costs', type: :replace_inner_html, value: sub_totals[:costs]),
      OpenStruct.new(dom_id: 'sr_totals_vat', type: :replace_inner_html, value: sub_totals[:vat]),
      OpenStruct.new(dom_id: 'sr_totals_total', type: :replace_inner_html, value: sub_totals[:total])
    ]
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/BlockLength
