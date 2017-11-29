# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/BlockLength

class Framework < Roda
  route 'target_markets', 'masterfiles' do |r|
    # TARGET MARKETS
    # --------------------------------------------------------------------------
    r.on 'target_markets', Integer do |id|
      interactor = TargetMarketInteractor.new(current_user, {}, {}, {})

      # Check for notfound:
      r.on !interactor.exists?(:target_markets, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        if authorised?('target_markets', 'edit')
          show_partial { Masterfiles::TargetMarkets::TargetMarket::Edit.call(id) }
        else
          dialog_permission_error
        end
      end
      r.is do
        r.get do       # SHOW
          if authorised?('target_markets', 'read')
            show_partial { Masterfiles::TargetMarkets::TargetMarket::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          response['Content-Type'] = 'application/json'
          res = interactor.update_target_market(id, params[:target_market])
          if res.success
            update_grid_row(id, changes: { target_market_name: res.instance[:target_market_name] },
                                notice:  res.message)
          else
            content = show_partial { Masterfiles::TargetMarkets::TargetMarket::Edit.call(id, params[:target_market], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          response['Content-Type'] = 'application/json'
          res = interactor.delete_target_market(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'target_markets' do
      interactor = TargetMarketInteractor.new(current_user, {}, {}, {})
      r.on 'new' do    # NEW
        if authorised?('target_markets', 'new')
          show_partial_or_page(fetch?(r)) { Masterfiles::TargetMarkets::TargetMarket::New.call(remote: fetch?(r)) }
        else
          fetch?(r) ? dialog_permission_error : show_unauthorised
        end
      end
      r.post do        # CREATE
        res = interactor.create_target_market(params[:target_market])
        if res.success
          flash[:notice] = res.message
          if fetch?(r)
            redirect_via_json_to_last_grid
          else
            redirect_to_last_grid(r)
          end
        elsif fetch?(r)
          content = show_partial do
            Masterfiles::TargetMarkets::TargetMarket::New.call(form_values: params[:target_market],
                                                               form_errors: res.errors,
                                                               remote: true)
          end
          update_dialog_content(content: content, error: res.message)
        else
          flash[:error] = res.message
          show_page do
            Masterfiles::TargetMarkets::TargetMarket::New.call(form_values: params[:target_market],
                                                               form_errors: res.errors,
                                                               remote: false)
          end
        end
      end
    end
  end
end
