# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/BlockLength

class Framework < Roda
  route 'target_markets', 'masterfiles' do |r|
    # TARGET MARKET GROUP TYPES
    # --------------------------------------------------------------------------
    r.on 'target_market_group_types', Integer do |id|
      interactor = TargetMarketInteractor.new(current_user, {}, {}, {})

      # Check for notfound:
      r.on !interactor.exists?(:target_market_group_types, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        if authorised?('fruit', 'edit')
          show_partial { Masterfiles::Fruit::TargetMarketGroupType::Edit.call(id) }
        else
          dialog_permission_error
        end
      end
      r.is do
        r.get do       # SHOW
          if authorised?('fruit', 'read')
            show_partial { Masterfiles::Fruit::TargetMarketGroupType::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          response['Content-Type'] = 'application/json'
          res = interactor.update_tm_group_type(id, params[:target_market_group_type])
          if res.success
            update_grid_row(id, changes: { target_market_group_type_code: res.instance[:target_market_group_type_code] },
                            notice:  res.message)
          else
            content = show_partial { Masterfiles::Fruit::TargetMarketGroupType::Edit.call(id, params[:target_market_group_type], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          response['Content-Type'] = 'application/json'
          res = interactor.delete_tm_group_type(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'target_market_group_types' do
      interactor = TargetMarketInteractor.new(current_user, {}, {}, {})
      r.on 'new' do    # NEW
        if authorised?('fruit', 'new')
          show_partial_or_page(fetch?(r)) { Masterfiles::Fruit::TargetMarketGroupType::New.call(remote: fetch?(r)) }
        else
          fetch?(r) ? dialog_permission_error : show_unauthorised
        end
      end
      r.post do        # CREATE
        res = interactor.create_tm_group_type(params[:target_market_group_type])
        if res.success
          flash[:notice] = res.message
          if fetch?(r)
            redirect_via_json_to_last_grid
          else
            redirect_to_last_grid(r)
          end
        elsif fetch?(r)
          content = show_partial do
            Masterfiles::Fruit::TargetMarketGroupType::New.call(form_values: params[:target_market_group_type],
                                                                form_errors: res.errors,
                                                                remote: true)
          end
          update_dialog_content(content: content, error: res.message)
        else
          flash[:error] = res.message
          show_page do
            Masterfiles::Fruit::TargetMarketGroupType::New.call(form_values: params[:target_market_group_type],
                                                                form_errors: res.errors,
                                                                remote: false)
          end
        end
      end
    end
    # TARGET MARKET GROUPS
    # --------------------------------------------------------------------------
    r.on 'target_market_groups', Integer do |id|
      interactor = TargetMarketInteractor.new(current_user, {}, {}, {})

      # Check for notfound:
      r.on !interactor.exists?(:target_market_groups, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        if authorised?('fruit', 'edit')
          show_partial { Masterfiles::Fruit::TargetMarketGroup::Edit.call(id) }
        else
          dialog_permission_error
        end
      end
      r.is do
        r.get do       # SHOW
          if authorised?('fruit', 'read')
            show_partial { Masterfiles::Fruit::TargetMarketGroup::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          response['Content-Type'] = 'application/json'
          res = interactor.update_tm_group(id, params[:target_market_group])
          if res.success
            update_grid_row(id, changes: { target_market_group_type_id: res.instance[:target_market_group_type_id], target_market_group_name: res.instance[:target_market_group_name] },
                            notice:  res.message)
          else
            content = show_partial { Masterfiles::Fruit::TargetMarketGroup::Edit.call(id, params[:target_market_group], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          response['Content-Type'] = 'application/json'
          res = interactor.delete_tm_group(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'target_market_groups' do
      interactor = TargetMarketInteractor.new(current_user, {}, {}, {})
      r.on 'new' do    # NEW
        if authorised?('fruit', 'new')
          show_partial_or_page(fetch?(r)) { Masterfiles::Fruit::TargetMarketGroup::New.call(remote: fetch?(r)) }
        else
          fetch?(r) ? dialog_permission_error : show_unauthorised
        end
      end
      r.post do        # CREATE
        res = interactor.create_tm_group(params[:target_market_group])
        if res.success
          flash[:notice] = res.message
          if fetch?(r)
            redirect_via_json_to_last_grid
          else
            redirect_to_last_grid(r)
          end
        elsif fetch?(r)
          content = show_partial do
            Masterfiles::Fruit::TargetMarketGroup::New.call(form_values: params[:target_market_group],
                                                            form_errors: res.errors,
                                                            remote: true)
          end
          update_dialog_content(content: content, error: res.message)
        else
          flash[:error] = res.message
          show_page do
            Masterfiles::Fruit::TargetMarketGroup::New.call(form_values: params[:target_market_group],
                                                            form_errors: res.errors,
                                                            remote: false)
          end
        end
      end
    end
    # TARGET MARKETS
    # --------------------------------------------------------------------------
    r.on 'target_markets', Integer do |id|
      interactor = TargetMarketInteractor.new(current_user, {}, {}, {})

      # Check for notfound:
      r.on !interactor.exists?(:target_markets, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        if authorised?('fruit', 'edit')
          show_partial { Masterfiles::Fruit::TargetMarket::Edit.call(id) }
        else
          dialog_permission_error
        end
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
          if authorised?('fruit', 'read')
            show_partial { Masterfiles::Fruit::TargetMarket::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          response['Content-Type'] = 'application/json'
          res = interactor.update_target_market(id, params[:target_market])
          if res.success
            update_grid_row(id, changes: { target_market_name: res.instance[:target_market_name] }, notice: res.message)
          else
            content = show_partial { Masterfiles::Fruit::TargetMarket::Edit.call(id, params[:target_market], res.errors) }
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
        if authorised?('fruit', 'new')
          show_partial_or_page(fetch?(r)) { Masterfiles::Fruit::TargetMarket::New.call(remote: fetch?(r)) }
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
            Masterfiles::Fruit::TargetMarket::New.call(form_values: params[:target_market],
                                                       form_errors: res.errors,
                                                       remote: true)
          end
          update_dialog_content(content: content, error: res.message)
        else
          flash[:error] = res.message
          show_page do
            Masterfiles::Fruit::TargetMarket::New.call(form_values: params[:target_market],
                                                       form_errors: res.errors,
                                                       remote: false)
          end
        end
      end
    end
    # DESTINATION CITIES
    # --------------------------------------------------------------------------
    r.on 'destination_cities', Integer do |id|
      interactor = DestinationInteractor.new(current_user, {}, {}, {})

      # Check for notfound:
      r.on !interactor.exists?(:destination_cities, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        if authorised?('fruit', 'edit')
          show_partial { Masterfiles::Fruit::DestinationCity::Edit.call(id) }
        else
          dialog_permission_error
        end
      end
      r.is do
        r.get do       # SHOW
          if authorised?('fruit', 'read')
            show_partial { Masterfiles::Fruit::DestinationCity::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          response['Content-Type'] = 'application/json'
          res = interactor.update_city(id, params[:destination_city])
          if res.success
            update_grid_row(id, changes: { destination_country_id: res.instance[:destination_country_id], city_name: res.instance[:city_name] },
                            notice:  res.message)
          else
            content = show_partial { Masterfiles::Fruit::DestinationCity::Edit.call(id, params[:destination_city], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          response['Content-Type'] = 'application/json'
          res = interactor.delete_city(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'destination_cities' do
      interactor = DestinationInteractor.new(current_user, {}, {}, {})
      r.on 'new' do    # NEW
        if authorised?('fruit', 'new')
          show_partial_or_page(fetch?(r)) { Masterfiles::Fruit::DestinationCity::New.call(remote: fetch?(r)) }
        else
          fetch?(r) ? dialog_permission_error : show_unauthorised
        end
      end
      r.post do        # CREATE
        res = interactor.create_city(params[:destination_city])
        if res.success
          flash[:notice] = res.message
          if fetch?(r)
            redirect_via_json_to_last_grid
          else
            redirect_to_last_grid(r)
          end
        elsif fetch?(r)
          content = show_partial do
            Masterfiles::Fruit::DestinationCity::New.call(form_values: params[:destination_city],
                                                          form_errors: res.errors,
                                                          remote: true)
          end
          update_dialog_content(content: content, error: res.message)
        else
          flash[:error] = res.message
          show_page do
            Masterfiles::Fruit::DestinationCity::New.call(form_values: params[:destination_city],
                                                          form_errors: res.errors,
                                                          remote: false)
          end
        end
      end
    end
    # DESTINATION COUNTRIES
    # --------------------------------------------------------------------------
    r.on 'destination_countries', Integer do |id|
      interactor = DestinationInteractor.new(current_user, {}, {}, {})

      # Check for notfound:
      r.on !interactor.exists?(:destination_countries, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        if authorised?('fruit', 'edit')
          show_partial { Masterfiles::Fruit::DestinationCountry::Edit.call(id) }
        else
          dialog_permission_error
        end
      end
      r.is do
        r.get do       # SHOW
          if authorised?('fruit', 'read')
            show_partial { Masterfiles::Fruit::DestinationCountry::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          response['Content-Type'] = 'application/json'
          res = interactor.update_country(id, params[:destination_country])
          if res.success
            update_grid_row(id, changes: { destination_region_id: res.instance[:destination_region_id], country_name: res.instance[:country_name] },
                            notice:  res.message)
          else
            content = show_partial { Masterfiles::Fruit::DestinationCountry::Edit.call(id, params[:destination_country], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          response['Content-Type'] = 'application/json'
          res = interactor.delete_country(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'destination_countries' do
      interactor = DestinationInteractor.new(current_user, {}, {}, {})
      r.on 'new' do    # NEW
        if authorised?('fruit', 'new')
          show_partial_or_page(fetch?(r)) { Masterfiles::Fruit::DestinationCountry::New.call(remote: fetch?(r)) }
        else
          fetch?(r) ? dialog_permission_error : show_unauthorised
        end
      end
      r.post do        # CREATE
        res = interactor.create_country(params[:destination_country])
        if res.success
          flash[:notice] = res.message
          if fetch?(r)
            redirect_via_json_to_last_grid
          else
            redirect_to_last_grid(r)
          end
        elsif fetch?(r)
          content = show_partial do
            Masterfiles::Fruit::DestinationCountry::New.call(form_values: params[:destination_country],
                                                             form_errors: res.errors,
                                                             remote: true)
          end
          update_dialog_content(content: content, error: res.message)
        else
          flash[:error] = res.message
          show_page do
            Masterfiles::Fruit::DestinationCountry::New.call(form_values: params[:destination_country],
                                                             form_errors: res.errors,
                                                             remote: false)
          end
        end
      end
    end
    # DESTINATION REGIONS
    # --------------------------------------------------------------------------
    r.on 'destination_regions', Integer do |id|
      interactor = DestinationInteractor.new(current_user, {}, {}, {})

      # Check for notfound:
      r.on !interactor.exists?(:destination_regions, id) do
        handle_not_found(r)
      end

      r.on 'destination_countries' do
        show_partial { Masterfiles::Fruit::DestinationCountry::Edit.call(1) } #TODO: Show countries grid here (redirect, Not multiselect)
      end
      r.on 'edit' do   # EDIT
        if authorised?('fruit', 'edit')
          show_partial { Masterfiles::Fruit::DestinationRegion::Edit.call(id) }
        else
          dialog_permission_error
        end
      end
      r.is do
        r.get do       # SHOW
          if authorised?('fruit', 'read')
            show_partial { Masterfiles::Fruit::DestinationRegion::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          response['Content-Type'] = 'application/json'
          res = interactor.update_region(id, params[:destination_region])
          if res.success
            update_grid_row(id, changes: { destination_region_name: res.instance[:destination_region_name] },
                            notice:  res.message)
          else
            content = show_partial { Masterfiles::Fruit::DestinationRegion::Edit.call(id, params[:destination_region], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          response['Content-Type'] = 'application/json'
          res = interactor.delete_region(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'destination_regions' do
      interactor = DestinationInteractor.new(current_user, {}, {}, {})
      r.on 'new' do    # NEW
        if authorised?('fruit', 'new')
          show_partial_or_page(fetch?(r)) { Masterfiles::Fruit::DestinationRegion::New.call(remote: fetch?(r)) }
        else
          fetch?(r) ? dialog_permission_error : show_unauthorised
        end
      end
      r.post do        # CREATE
        res = interactor.create_region(params[:destination_region])
        if res.success
          flash[:notice] = res.message
          if fetch?(r)
            redirect_via_json_to_last_grid
          else
            redirect_to_last_grid(r)
          end
        elsif fetch?(r)
          content = show_partial do
            Masterfiles::Fruit::DestinationRegion::New.call(form_values: params[:destination_region],
                                                            form_errors: res.errors,
                                                            remote: true)
          end
          update_dialog_content(content: content, error: res.message)
        else
          flash[:error] = res.message
          show_page do
            Masterfiles::Fruit::DestinationRegion::New.call(form_values: params[:destination_region],
                                                            form_errors: res.errors,
                                                            remote: false)
          end
        end
      end
    end
  end
end
