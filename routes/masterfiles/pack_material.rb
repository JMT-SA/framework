# frozen_string_literal: true

class Framework < Roda
  route 'pack_material', 'masterfiles' do |r| # rubocop:disable Metrics/BlockLength
    # ACCOUNT CODES
    # --------------------------------------------------------------------------
    r.on 'account_codes', Integer do |id| # rubocop:disable Metrics/BlockLength
      interactor = MasterfilesApp::AccountCodeInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})

      # Check for notfound:
      r.on !interactor.exists?(:account_codes, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('pack material', 'edit')
        show_partial { Masterfiles::PackMaterial::AccountCode::Edit.call(id) }
      end

      r.is do
        r.get do       # SHOW
          check_auth!('pack material', 'read')
          show_partial { Masterfiles::PackMaterial::AccountCode::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_account_code(id, params[:account_code])
          if res.success
            update_grid_row(id, changes: { account_code: res.instance[:account_code], description: res.instance[:description] },
                                notice: res.message)
          else
            re_show_form(r, res) { Masterfiles::PackMaterial::AccountCode::Edit.call(id, form_values: params[:account_code], form_errors: res.errors) }
          end
        end
        r.delete do    # DELETE
          check_auth!('pack material', 'delete')
          res = interactor.delete_account_code(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end

    r.on 'account_codes' do
      interactor = MasterfilesApp::AccountCodeInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})
      r.on 'new' do    # NEW
        check_auth!('pack material', 'new')
        show_partial_or_page(r) { Masterfiles::PackMaterial::AccountCode::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_account_code(params[:account_code])
        if res.success
          row_keys = %i[
            id
            account_code
            description
          ]
          add_grid_row(attrs: select_attributes(res.instance, row_keys),
                       notice: res.message)
        else
          re_show_form(r, res, url: '/masterfiles/pack_material/account_codes/new') do
            Masterfiles::PackMaterial::AccountCode::New.call(form_values: params[:account_code],
                                                             form_errors: res.errors,
                                                             remote: fetch?(r))
          end
        end
      end
    end
  end
end
