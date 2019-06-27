# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/BlockLength

class Framework < Roda
  route 'general', 'masterfiles' do |r|
    # UOM TYPES
    # --------------------------------------------------------------------------
    r.on 'uom_types', Integer do |id|
      interactor = MasterfilesApp::UomTypeInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:uom_types, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('general', 'edit')
        show_partial { Masterfiles::General::UomType::Edit.call(id) }
      end
      r.is do
        r.get do       # SHOW
          check_auth!('general', 'read')
          show_partial { Masterfiles::General::UomType::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_uom_type(id, params[:uom_type])
          if res.success
            update_grid_row(id, changes: { code: res.instance[:code] },
                                notice: res.message)
          else
            re_show_form(r, res) { Masterfiles::General::UomType::Edit.call(id, form_values: params[:uom_type], form_errors: res.errors) }
          end
        end
        r.delete do    # DELETE
          check_auth!('general', 'delete')
          res = interactor.delete_uom_type(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end

    r.on 'uom_types' do
      interactor = MasterfilesApp::UomTypeInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do    # NEW
        check_auth!('general', 'new')
        show_partial_or_page(r) { Masterfiles::General::UomType::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_uom_type(params[:uom_type])
        if res.success
          row_keys = %i[
            id
            code
          ]
          add_grid_row(attrs: select_attributes(res.instance, row_keys),
                       notice: res.message)
        else
          re_show_form(r, res, url: '/masterfiles/general/uom_types/new') do
            Masterfiles::General::UomType::New.call(form_values: params[:uom_type],
                                                    form_errors: res.errors,
                                                    remote: fetch?(r))
          end
        end
      end
    end

    # UOMS
    # --------------------------------------------------------------------------
    r.on 'uoms', Integer do |id|
      interactor = MasterfilesApp::UomInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:uoms, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('general', 'edit')
        show_partial { Masterfiles::General::Uom::Edit.call(id) }
      end
      r.is do
        r.get do       # SHOW
          check_auth!('general', 'read')
          show_partial { Masterfiles::General::Uom::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_uom(id, params[:uom])
          if res.success
            update_grid_row(id,
                            changes: { uom_type_id: res.instance[:uom_type_id], uom_code: res.instance[:uom_code] },
                            notice: res.message)
          else
            re_show_form(r, res) { Masterfiles::General::Uom::Edit.call(id, form_values: params[:uom], form_errors: res.errors) }
          end
        end
        r.delete do    # DELETE
          check_auth!('general', 'delete')
          res = interactor.delete_uom(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end

    r.on 'uoms' do
      interactor = MasterfilesApp::UomInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do    # NEW
        check_auth!('general', 'new')
        show_partial_or_page(r) { Masterfiles::General::Uom::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_uom(params[:uom])
        if res.success
          row_keys = %i[
            id
            uom_type_id
            uom_type_code
            uom_code
          ]
          add_grid_row(attrs: select_attributes(res.instance, row_keys),
                       notice: res.message)
        else
          re_show_form(r, res, url: '/masterfiles/general/uoms/new') do
            Masterfiles::General::Uom::New.call(form_values: params[:uom],
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
