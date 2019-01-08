# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength

class Framework < Roda
  route 'config', 'masterfiles' do |r|
    # LABEL TEMPLATES
    # --------------------------------------------------------------------------
    r.on 'label_templates', Integer do |id|
      interactor = MasterfilesApp::LabelTemplateInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:label_templates, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('config', 'edit')
        show_partial { Masterfiles::Config::LabelTemplate::Edit.call(id) }
      end
      r.on 'get_variables' do
        r.get do
          check_auth!('config', 'edit')
          show_partial { Masterfiles::Config::LabelTemplate::Variables.call(id) }
        end
        r.patch do
          res = interactor.get_variables(id, params[:label_template])
          if res.success
            show_partial(notice: res.message) { Masterfiles::Config::LabelTemplate::Show.call(id) }
          else
            re_show_form(r, res) { Masterfiles::Config::LabelTemplate::Variables.call(id, form_values: params[:label_template], form_errors: res.errors) }
          end
        end
      end
      r.is do
        r.get do       # SHOW
          check_auth!('config', 'read')
          show_partial { Masterfiles::Config::LabelTemplate::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_label_template(id, params[:label_template])
          if res.success
            row_keys = %i[
              label_template_name
              description
              application
              active
            ]
            update_grid_row(id, changes: select_attributes(res.instance, row_keys), notice: res.message)
          else
            re_show_form(r, res) { Masterfiles::Config::LabelTemplate::Edit.call(id, form_values: params[:label_template], form_errors: res.errors) }
          end
        end
        r.delete do    # DELETE
          check_auth!('config', 'delete')
          res = interactor.delete_label_template(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end

    r.on 'label_templates' do
      interactor = MasterfilesApp::LabelTemplateInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do    # NEW
        check_auth!('config', 'new')
        show_partial_or_page(r) { Masterfiles::Config::LabelTemplate::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_label_template(params[:label_template])
        if res.success
          row_keys = %i[
            id
            label_template_name
            description
            application
            active
          ]
          add_grid_row(attrs: select_attributes(res.instance, row_keys),
                       notice: res.message)
        else
          re_show_form(r, res, url: '/masterfiles/config/label_templates/new') do
            Masterfiles::Config::LabelTemplate::New.call(form_values: params[:label_template],
                                                         form_errors: res.errors,
                                                         remote: fetch?(r))
          end
        end
      end
    end
  end
end

# rubocop:enable Metrics/BlockLength