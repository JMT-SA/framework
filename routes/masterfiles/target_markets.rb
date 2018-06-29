# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/BlockLength

class Framework < Roda
  route 'target_markets', 'masterfiles' do |r|
    # TARGET MARKET GROUP TYPES
    # --------------------------------------------------------------------------
    r.on 'target_market_group_types', Integer do |id|
      interactor = MasterfilesApp::TargetMarketInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:target_market_group_types, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('Target Markets', 'edit')
        show_partial { Masterfiles::TargetMarkets::TmGroupType::Edit.call(id) }
      end
      r.is do
        r.get do       # SHOW
          check_auth!('Target Markets', 'read')
          show_partial { Masterfiles::TargetMarkets::TmGroupType::Show.call(id) }
        end
        r.patch do     # UPDATE
          return_json_response
          res = interactor.update_tm_group_type(id, params[:tm_group_type])
          if res.success
            update_grid_row(id, changes: { target_market_group_type_code: res.instance[:target_market_group_type_code] },
                            notice: res.message)
          else
            content = show_partial { Masterfiles::TargetMarkets::TmGroupType::Edit.call(id, params[:tm_group_type], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          return_json_response
          check_auth!('Target Markets', 'delete')
          res = interactor.delete_tm_group_type(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'target_market_group_types' do
      interactor = MasterfilesApp::TargetMarketInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do    # NEW
        check_auth!('Target Markets', 'new')
        show_partial_or_page(r) { Masterfiles::TargetMarkets::TmGroupType::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_tm_group_type(params[:tm_group_type])
        if res.success
          flash[:notice] = res.message
          redirect_to_last_grid(r)
        else
          re_show_form(r, res, url: '/masterfiles/target_markets/target_market_group_types/new') do
            Masterfiles::TargetMarkets::TmGroupType::New.call(form_values: params[:tm_group_type],
                                                              form_errors: res.errors,
                                                              remote: fetch?(r))
          end
        end
      end
    end
    # TARGET MARKET GROUPS
    # --------------------------------------------------------------------------
    r.on 'target_market_groups', Integer do |id|
      interactor = MasterfilesApp::TargetMarketInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:target_market_groups, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('Target Markets', 'edit')
        show_partial { Masterfiles::TargetMarkets::TmGroup::Edit.call(id) }
      end
      r.is do
        r.get do       # SHOW
          check_auth!('Target Markets', 'read')
          show_partial { Masterfiles::TargetMarkets::TmGroup::Show.call(id) }
        end
        r.patch do     # UPDATE
          return_json_response
          res = interactor.update_tm_group(id, params[:tm_group])
          if res.success
            update_grid_row(id, changes: { target_market_group_type_id: res.instance[:target_market_group_type_id],
                                           target_market_group_name: res.instance[:target_market_group_name] },
                            notice: res.message)
          else
            content = show_partial { Masterfiles::TargetMarkets::TmGroup::Edit.call(id, params[:tm_group], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          return_json_response
          check_auth!('Target Markets', 'delete')
          res = interactor.delete_tm_group(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'target_market_groups' do
      interactor = MasterfilesApp::TargetMarketInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do    # NEW
        check_auth!('Target Markets', 'new')
        show_partial_or_page(r) { Masterfiles::TargetMarkets::TmGroup::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_tm_group(params[:tm_group])
        if res.success
          flash[:notice] = res.message
          redirect_to_last_grid(r)
        else
          re_show_form(r, res, url: '/masterfiles/target_markets/target_market_groups/new') do
            Masterfiles::TargetMarkets::TmGroup::New.call(form_values: params[:tm_group],
                                                          form_errors: res.errors,
                                                          remote: fetch?(r))
          end
        end
      end
    end
    # TARGET MARKETS
    # --------------------------------------------------------------------------
    r.on 'target_markets', Integer do |id|
      interactor = MasterfilesApp::TargetMarketInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:target_markets, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('Target Markets', 'edit')
        show_partial { Masterfiles::TargetMarkets::TargetMarket::Edit.call(id) }
      end
      r.on 'link_countries' do
        r.post do
          res = interactor.link_countries(id, multiselect_grid_choices(params))

          if res.success
            flash[:notice] = res.message
          else
            flash[:error] = res.message
          end
          r.redirect "/list/target_market_countries/multi?key=target_markets&id=#{id}"
        end
      end
      r.on 'link_tm_groups' do
        r.post do
          res = interactor.link_tm_groups(id, multiselect_grid_choices(params))

          if res.success
            flash[:notice] = res.message
          else
            flash[:error] = res.message
          end
          r.redirect "/list/target_market_tm_groups/multi?key=target_markets&id=#{id}"
        end
      end
      r.is do
        r.get do       # SHOW
          check_auth!('Target Markets', 'read')
          show_partial { Masterfiles::TargetMarkets::TargetMarket::Show.call(id) }
        end
        r.patch do     # UPDATE
          return_json_response
          res = interactor.update_target_market(id, params[:target_market])
          if res.success
            update_grid_row(id, changes: { target_market_name: res.instance[:target_market_name] },
                            notice: res.message)
          else
            content = show_partial { Masterfiles::TargetMarkets::TargetMarket::Edit.call(id, params[:target_market], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          return_json_response
          check_auth!('Target Markets', 'delete')
          res = interactor.delete_target_market(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'target_markets' do
      interactor = MasterfilesApp::TargetMarketInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do    # NEW
        check_auth!('Target Markets', 'new')
        show_partial_or_page(r) { Masterfiles::TargetMarkets::TargetMarket::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_target_market(params[:target_market])
        if res.success
          flash[:notice] = res.message
          redirect_to_last_grid(r)
        else
          re_show_form(r, res, url: '/masterfiles/target_markets/target_markets/new') do
            Masterfiles::TargetMarkets::TargetMarket::New.call(form_values: params[:target_market],
                                                               form_errors: res.errors,
                                                               remote: fetch?(r))
          end
        end
      end
    end
    # DESTINATION REGIONS
    # --------------------------------------------------------------------------
    r.on 'destination_regions', Integer do |id|
      interactor = MasterfilesApp::DestinationInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:destination_regions, id) do
        handle_not_found(r)
      end
      r.on 'edit' do   # EDIT
        check_auth!('Target Markets', 'edit')
        show_partial { Masterfiles::TargetMarkets::Region::Edit.call(id) }
      end
      r.on 'destination_countries' do
        country_interactor = MasterfilesApp::DestinationInteractor.new(current_user, {}, { route_url: request.path }, {})
        r.on 'new' do    # NEW
          check_auth!('Target Markets', 'new')
          show_partial_or_page(r) { Masterfiles::TargetMarkets::Country::New.call(id, remote: fetch?(r)) }
        end
        r.post do        # CREATE
          res = country_interactor.create_country(id, params[:country])
          if res.success
            flash[:notice] = res.message
            redirect_to_last_grid(r)
          else
            re_show_form(r, res, url: "/masterfiles/target_markets/destination_regions/#{id}/destination_countries/new") do
              Masterfiles::TargetMarkets::Country::New.call(id,
                                                            form_values: params[:country],
                                                            form_errors: res.errors,
                                                            remote: fetch?(r))
            end
          end
        end
      end
      r.is do
        r.get do       # SHOW
          check_auth!('Target Markets', 'read')
          show_partial { Masterfiles::TargetMarkets::Region::Show.call(id) }
        end
        r.patch do     # UPDATE
          return_json_response
          res = interactor.update_region(id, params[:region])
          if res.success
            update_grid_row(id, changes: { destination_region_name: res.instance[:destination_region_name] },
                            notice: res.message)
          else
            content = show_partial { Masterfiles::TargetMarkets::Region::Edit.call(id, params[:region], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          return_json_response
          check_auth!('Target Markets', 'delete')
          res = interactor.delete_region(id)

          if res.success
            delete_grid_row(id, notice: res.message)
          else
            show_json_error(res.message)
          end
        end
      end
    end
    r.on 'destination_regions' do
      interactor = MasterfilesApp::DestinationInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do    # NEW
        check_auth!('Target Markets', 'new')
        show_partial_or_page(r) { Masterfiles::TargetMarkets::Region::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_region(params[:region])
        if res.success
          flash[:notice] = res.message
          redirect_to_last_grid(r)
        else
          re_show_form(r, res, url: '/masterfiles/target_markets/destination_regions/new') do
            Masterfiles::TargetMarkets::Region::New.call(form_values: params[:region],
                                                         form_errors: res.errors,
                                                         remote: fetch?(r))
          end
        end
      end
    end
    # DESTINATION COUNTRIES
    # --------------------------------------------------------------------------
    r.on 'destination_countries', Integer do |id|
      interactor = MasterfilesApp::DestinationInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:destination_countries, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('Target Markets', 'edit')
        show_partial { Masterfiles::TargetMarkets::Country::Edit.call(id) }
      end
      r.on 'destination_cities' do
        r.on 'new' do    # NEW
          check_auth!('Target Markets', 'new')
          show_partial_or_page(r) { Masterfiles::TargetMarkets::City::New.call(id, remote: fetch?(r)) }
        end
        r.post do        # CREATE
          res = interactor.create_city(id, params[:city])
          if res.success
            flash[:notice] = res.message
            redirect_to_last_grid(r)
          else
            re_show_form(r, res, url: "/masterfiles/target_markets/destination_countries/#{id}/destination_cities/new") do
              Masterfiles::TargetMarkets::City::New.call(id,
                                                            form_values: params[:city],
                                                            form_errors: res.errors,
                                                            remote: fetch?(r))
            end
          end
        end
      end
      r.is do
        r.get do       # SHOW
          check_auth!('Target Markets', 'read')
          show_partial { Masterfiles::TargetMarkets::Country::Show.call(id) }
        end
        r.patch do     # UPDATE
          return_json_response
          res = interactor.update_country(id, params[:country])
          if res.success
            update_grid_row(id,
                            changes: { destination_region_id: res.instance[:destination_region_id],
                                       country_name: res.instance[:country_name] },
                            notice: res.message)
          else
            content = show_partial { Masterfiles::TargetMarkets::Country::Edit.call(id, params[:country], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          return_json_response
          check_auth!('Target Markets', 'delete')
          res = interactor.delete_country(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            show_json_error(res.message)
          end
        end
      end
    end
    # DESTINATION CITIES
    # --------------------------------------------------------------------------
    r.on 'destination_cities', Integer do |id|
      interactor = MasterfilesApp::DestinationInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:destination_cities, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('Target Markets', 'edit')
        show_partial { Masterfiles::TargetMarkets::City::Edit.call(id) }
      end
      r.is do
        r.get do       # SHOW
          check_auth!('Target Markets', 'read')
          show_partial { Masterfiles::TargetMarkets::City::Show.call(id) }
        end
        r.patch do     # UPDATE
          return_json_response
          res = interactor.update_city(id, params[:city])
          if res.success
            update_grid_row(id,
                            changes: { destination_country_id: res.instance[:destination_country_id],
                                       city_name: res.instance[:city_name] },
                            notice: res.message)
          else
            content = show_partial { Masterfiles::TargetMarkets::City::Edit.call(id, params[:city], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          return_json_response
          check_auth!('Target Markets', 'delete')
          res = interactor.delete_city(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
  end
end
