# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/BlockLength

class Framework < Roda
  route 'fruit', 'masterfiles' do |r|
    # COMMODITY GROUPS
    # --------------------------------------------------------------------------
    r.on 'commodity_groups', Integer do |id|
      repo = CommodityGroupRepo.new
      commodity_group = repo.find(id)

      # Check for notfound:
      r.on commodity_group.nil? do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        begin
          if authorised?('fruit', 'edit')
            show_partial { Masterfiles::Fruit::CommodityGroup::Edit.call(id) }
          else
            dialog_permission_error
          end
        rescue StandardError => e
          dialog_error(e)
        end
      end
      r.is do
        r.get do       # SHOW
          if authorised?('fruit', 'read')
            show_partial { Masterfiles::Fruit::CommodityGroup::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          begin
            response['Content-Type'] = 'application/json'
            res = CommodityGroupSchema.call(params[:commodity_group])
            errors = res.messages
            if errors.empty?
              repo = CommodityGroupRepo.new
              repo.update(id, res)
              update_grid_row(id, changes: { code: res[:code], description: res[:description], active: res[:active] },
                                  notice:  "Updated #{res[:code]}")
            else
              content = show_partial { Masterfiles::Fruit::CommodityGroup::Edit.call(id, params[:commodity_group], errors) }
              update_dialog_content(content: content, error: 'Validation error')
            end
          rescue StandardError => e
            handle_json_error(e)
          end
        end
        r.delete do    # DELETE
          response['Content-Type'] = 'application/json'
          repo = CommodityGroupRepo.new
          repo.delete(id)
          delete_grid_row(id, notice: 'Deleted')
        end
      end
    end
    r.on 'commodity_groups' do
      r.on 'new' do    # NEW
        begin
          if authorised?('fruit', 'new')
            show_partial { Masterfiles::Fruit::CommodityGroup::New.call }
          else
            dialog_permission_error
          end
        rescue StandardError => e
          dialog_error(e)
        end
      end
      r.post do        # CREATE
        res = CommodityGroupSchema.call(params[:commodity_group])
        errors = res.messages
        if errors.empty?
          repo = CommodityGroupRepo.new
          repo.create(res)
          flash[:notice] = 'Created'
          redirect_via_json_to_last_grid
        else
          content = show_partial { Masterfiles::Fruit::CommodityGroup::New.call(params[:commodity_group], errors) }
          update_dialog_content(content: content, error: 'Validation error')
        end
      end
    end
    # COMMODITIES
    # --------------------------------------------------------------------------
    r.on 'commodities', Integer do |id|
      repo = CommodityRepo.new
      commodity = repo.find(id)

      # Check for notfound:
      r.on commodity.nil? do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        begin
          if authorised?('fruit', 'edit')
            show_partial { Masterfiles::Fruit::Commodity::Edit.call(id) }
          else
            dialog_permission_error
          end
        rescue StandardError => e
          dialog_error(e)
        end
      end
      r.is do
        r.get do       # SHOW
          if authorised?('fruit', 'read')
            show_partial { Masterfiles::Fruit::Commodity::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          begin
            response['Content-Type'] = 'application/json'
            res = CommoditySchema.call(params[:commodity])
            errors = res.messages
            if errors.empty?
              repo = CommodityRepo.new
              repo.update(id, res)
              update_grid_row(id, changes: { commodity_group_id: res[:commodity_group_id], code: res[:code], description: res[:description], hs_code: res[:hs_code], active: res[:active] },
                                  notice:  "Updated #{res[:code]}")
            else
              content = show_partial { Masterfiles::Fruit::Commodity::Edit.call(id, params[:commodity], errors) }
              update_dialog_content(content: content, error: 'Validation error')
            end
          rescue StandardError => e
            handle_json_error(e)
          end
        end
        r.delete do    # DELETE
          response['Content-Type'] = 'application/json'
          repo = CommodityRepo.new
          repo.delete(id)
          delete_grid_row(id, notice: 'Deleted')
        end
      end
    end
    r.on 'commodities' do
      r.on 'new' do    # NEW
        begin
          if authorised?('fruit', 'new')
            show_partial { Masterfiles::Fruit::Commodity::New.call }
          else
            dialog_permission_error
          end
        rescue StandardError => e
          dialog_error(e)
        end
      end
      r.post do        # CREATE
        res = CommoditySchema.call(params[:commodity])
        errors = res.messages
        puts errors.inspect
        if errors.empty?
          repo = CommodityRepo.new
          repo.create(res)
          flash[:notice] = 'Created'
          redirect_via_json_to_last_grid
        else
          content = show_partial { Masterfiles::Fruit::Commodity::New.call(params[:commodity], errors) }
          update_dialog_content(content: content, error: 'Validation error')
        end
      end
    end
    # CULTIVAR GROUPS
    # --------------------------------------------------------------------------
    r.on 'cultivar_groups', Integer do |id|
      interactor = CultivarInteractor.new(current_user, {}, {}, {})

      # Check for notfound:
      r.on !interactor.exists?(:cultivar_groups, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        if authorised?('fruit', 'edit')
          show_partial { Masterfiles::Fruit::CultivarGroup::Edit.call(id) }
        else
          dialog_permission_error
        end
      end
      r.is do
        r.get do       # SHOW
          if authorised?('fruit', 'read')
            show_partial { Masterfiles::Fruit::CultivarGroup::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          response['Content-Type'] = 'application/json'
          res = interactor.update_cultivar_group(id, params[:cultivar_group])
          if res.success
            update_grid_row(id, changes: { cultivar_group_code: res.instance[:cultivar_group_code], description: res.instance[:description] },
                            notice:  res.message)
          else
            content = show_partial { Masterfiles::Fruit::CultivarGroup::Edit.call(id, params[:cultivar_group], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          response['Content-Type'] = 'application/json'
          res = interactor.delete_cultivar_group(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'cultivar_groups' do
      interactor = CultivarInteractor.new(current_user, {}, {}, {})
      r.on 'new' do    # NEW
        if authorised?('fruit', 'new')
          show_partial_or_page(fetch?(r)) { Masterfiles::Fruit::CultivarGroup::New.call(remote: fetch?(r)) }
        else
          fetch?(r) ? dialog_permission_error : show_unauthorised
        end
      end
      r.post do        # CREATE
        res = interactor.create_cultivar_group(params[:cultivar_group])
        if res.success
          flash[:notice] = res.message
          if fetch?(r)
            redirect_via_json_to_last_grid
          else
            redirect_to_last_grid(r)
          end
        elsif fetch?(r)
          content = show_partial do
            Masterfiles::Fruit::CultivarGroup::New.call(form_values: params[:cultivar_group],
                                                        form_errors: res.errors,
                                                             remote: true)
          end
          update_dialog_content(content: content, error: res.message)
        else
          flash[:error] = res.message
          show_page do
            Masterfiles::Fruit::CultivarGroup::New.call(form_values: params[:cultivar_group],
                                                        form_errors: res.errors,
                                                        remote: false)
          end
        end
      end
    end
    # CULTIVARS
    # --------------------------------------------------------------------------
    r.on 'cultivars', Integer do |id|
      interactor = CultivarInteractor.new(current_user, {}, {}, {})

      # Check for notfound:
      r.on !interactor.exists?(:cultivars, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        if authorised?('fruit', 'edit')
          show_partial { Masterfiles::Fruit::Cultivar::Edit.call(id) }
        else
          dialog_permission_error
        end
      end

      # MARKETING VARIETIES
      # --------------------------------------------------------------------------
      r.on 'link_marketing_varieties' do
        r.post do
          interactor = CultivarInteractor.new(current_user, {}, {}, {})
          res = interactor.link_marketing_varieties(id, multiselect_grid_choices(params))

          if res.success
            flash[:notice] = res.message
          else
            flash[:error] = res.message
          end
          r.redirect "/list/cultivar_marketing_varieties/multi?key=cultivars&id=#{id}"
        end
      end
      r.on 'marketing_varieties' do
        interactor = CultivarInteractor.new(current_user, {}, {}, {})
        r.on 'new' do    # NEW
          if authorised?('fruit', 'new')
            show_partial_or_page(fetch?(r)) { Masterfiles::Fruit::MarketingVariety::New.call(id, remote: fetch?(r)) }
          else
            fetch?(r) ? dialog_permission_error : show_unauthorised
          end
        end
        r.post do        # CREATE
          res = interactor.create_marketing_variety(id, params[:marketing_variety])
          if res.success
            flash[:notice] = res.message
            if fetch?(r)
              redirect_via_json_to_last_grid
            else
              redirect_to_last_grid(r)
            end
          elsif fetch?(r)
            content = show_partial do
              Masterfiles::Fruit::MarketingVariety::New.call(parent_id: id,
                                                             form_values: params[:marketing_variety],
                                                             form_errors: res.errors,
                                                             remote: true)
            end
            update_dialog_content(content: content, error: res.message)
          else
            flash[:error] = res.message
            show_page do
              Masterfiles::Fruit::MarketingVariety::New.call(parent_id: id,
                                                             form_values: params[:marketing_variety],
                                                             form_errors: res.errors,
                                                             remote: false)
            end
          end
        end
      end
      r.is do
        r.get do       # SHOW
          if authorised?('fruit', 'read')
            show_partial { Masterfiles::Fruit::Cultivar::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          response['Content-Type'] = 'application/json'
          res = interactor.update_cultivar(id, params[:cultivar])
          if res.success
            update_grid_row(id, changes: { commodity_id: res.instance[:commodity_id], cultivar_group_id: res.instance[:cultivar_group_id], cultivar_name: res.instance[:cultivar_name], description: res.instance[:description] },
                            notice:  res.message)
          else
            content = show_partial { Masterfiles::Fruit::Cultivar::Edit.call(id, params[:cultivar], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          response['Content-Type'] = 'application/json'
          res = interactor.delete_cultivar(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'cultivars' do
      interactor = CultivarInteractor.new(current_user, {}, {}, {})
      r.on 'new' do    # NEW
        if authorised?('fruit', 'new')
          show_partial_or_page(fetch?(r)) { Masterfiles::Fruit::Cultivar::New.call(remote: fetch?(r)) }
        else
          fetch?(r) ? dialog_permission_error : show_unauthorised
        end
      end
      r.post do        # CREATE
        res = interactor.create_cultivar(params[:cultivar])
        if res.success
          flash[:notice] = res.message
          if fetch?(r)
            redirect_via_json_to_last_grid
          else
            redirect_to_last_grid(r)
          end
        elsif fetch?(r)
          content = show_partial do
            Masterfiles::Fruit::Cultivar::New.call(form_values: params[:cultivar],
                                                   form_errors: res.errors,
                                                       remote: true)
          end
          update_dialog_content(content: content, error: res.message)
        else
          flash[:error] = res.message
          show_page do
            Masterfiles::Fruit::Cultivar::New.call(form_values: params[:cultivar],
                                                   form_errors: res.errors,
                                                   remote: false)
          end
        end
      end
    end
    r.on 'marketing_varieties', Integer do |id|
      interactor = CultivarInteractor.new(current_user, {}, {}, {})

      # Check for notfound:
      r.on !interactor.exists?(:marketing_varieties, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        if authorised?('fruit', 'edit')
          show_partial { Masterfiles::Fruit::MarketingVariety::Edit.call(id) }
        else
          dialog_permission_error
        end
      end
      r.is do
        r.get do       # SHOW
          if authorised?('fruit', 'read')
            show_partial { Masterfiles::Fruit::MarketingVariety::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          response['Content-Type'] = 'application/json'
          res = interactor.update_marketing_variety(id, params[:marketing_variety])
          if res.success
            update_grid_row(id, changes: { marketing_variety_code: res.instance[:marketing_variety_code], description: res.instance[:description] },
            notice:  res.message)
          else
            content = show_partial { Masterfiles::Fruit::MarketingVariety::Edit.call(id, params[:marketing_variety], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
      end
    end
    # BASIC PACK CODES
    # --------------------------------------------------------------------------
    r.on 'basic_pack_codes', Integer do |id|
      interactor = BasicPackCodeInteractor.new(current_user, {}, {}, {})

      # Check for notfound:
      r.on !interactor.exists?(:basic_pack_codes, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        if authorised?('fruit', 'edit')
          show_partial { Masterfiles::Fruit::BasicPackCode::Edit.call(id) }
        else
          dialog_permission_error
        end
      end
      r.is do
        r.get do       # SHOW
          if authorised?('fruit', 'read')
            show_partial { Masterfiles::Fruit::BasicPackCode::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          response['Content-Type'] = 'application/json'
          res = interactor.update_basic_pack_code(id, params[:basic_pack_code])
          if res.success
            update_grid_row(id, changes: { basic_pack_code: res.instance[:basic_pack_code], description: res.instance[:description], length_mm: res.instance[:length_mm], width_mm: res.instance[:width_mm], height_mm: res.instance[:height_mm] },
                            notice:  res.message)
          else
            content = show_partial { Masterfiles::Fruit::BasicPackCode::Edit.call(id, params[:basic_pack_code], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          response['Content-Type'] = 'application/json'
          res = interactor.delete_basic_pack_code(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'basic_pack_codes' do
      interactor = BasicPackCodeInteractor.new(current_user, {}, {}, {})
      r.on 'new' do    # NEW
        if authorised?('fruit', 'new')
          show_partial_or_page(fetch?(r)) { Masterfiles::Fruit::BasicPackCode::New.call(remote: fetch?(r)) }
        else
          fetch?(r) ? dialog_permission_error : show_unauthorised
        end
      end
      r.post do        # CREATE
        res = interactor.create_basic_pack_code(params[:basic_pack_code])
        if res.success
          flash[:notice] = res.message
          if fetch?(r)
            redirect_via_json_to_last_grid
          else
            redirect_to_last_grid(r)
          end
        elsif fetch?(r)
          content = show_partial do
            Masterfiles::Fruit::BasicPackCode::New.call(form_values: params[:basic_pack_code],
                                                        form_errors: res.errors,
                                                            remote: true)
          end
          update_dialog_content(content: content, error: res.message)
        else
          flash[:error] = res.message
          show_page do
            Masterfiles::Fruit::BasicPackCode::New.call(form_values: params[:basic_pack_code],
                                                        form_errors: res.errors,
                                                        remote: false)
          end
        end
      end
    end
    # STANDARD PACK CODES
    # --------------------------------------------------------------------------
    r.on 'standard_pack_codes', Integer do |id|
      interactor = StandardPackCodeInteractor.new(current_user, {}, {}, {})

      # Check for notfound:
      r.on !interactor.exists?(:standard_pack_codes, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        if authorised?('fruit', 'edit')
          show_partial { Masterfiles::Fruit::StandardPackCode::Edit.call(id) }
        else
          dialog_permission_error
        end
      end
      r.is do
        r.get do       # SHOW
          if authorised?('fruit', 'read')
            show_partial { Masterfiles::Fruit::StandardPackCode::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          response['Content-Type'] = 'application/json'
          res = interactor.update_standard_pack_code(id, params[:standard_pack_code])
          if res.success
            update_grid_row(id, changes: { standard_pack_code: res.instance[:standard_pack_code] },
                            notice:  res.message)
          else
            content = show_partial { Masterfiles::Fruit::StandardPackCode::Edit.call(id, params[:standard_pack_code], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          response['Content-Type'] = 'application/json'
          res = interactor.delete_standard_pack_code(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'standard_pack_codes' do
      interactor = StandardPackCodeInteractor.new(current_user, {}, {}, {})
      r.on 'new' do    # NEW
        if authorised?('fruit', 'new')
          show_partial_or_page(fetch?(r)) { Masterfiles::Fruit::StandardPackCode::New.call(remote: fetch?(r)) }
        else
          fetch?(r) ? dialog_permission_error : show_unauthorised
        end
      end
      r.post do        # CREATE
        res = interactor.create_standard_pack_code(params[:standard_pack_code])
        if res.success
          flash[:notice] = res.message
          if fetch?(r)
            redirect_via_json_to_last_grid
          else
            redirect_to_last_grid(r)
          end
        elsif fetch?(r)
          content = show_partial do
            Masterfiles::Fruit::StandardPackCode::New.call(form_values: params[:standard_pack_code],
                                                           form_errors: res.errors,
                                                               remote: true)
          end
          update_dialog_content(content: content, error: res.message)
        else
          flash[:error] = res.message
          show_page do
            Masterfiles::Fruit::StandardPackCode::New.call(form_values: params[:standard_pack_code],
                                                           form_errors: res.errors,
                                                           remote: false)
          end
        end
      end
    end
    # STD FRUIT SIZE COUNTS
    # --------------------------------------------------------------------------
    r.on 'std_fruit_size_counts', Integer do |id|
      interactor = StdFruitSizeCountInteractor.new(current_user, {}, {}, {})

      # Check for notfound:
      r.on !interactor.exists?(:std_fruit_size_counts, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        if authorised?('fruit', 'edit')
          show_partial { Masterfiles::Fruit::StdFruitSizeCount::Edit.call(id) }
        else
          dialog_permission_error
        end
      end
      r.is do
        r.get do       # SHOW
          if authorised?('fruit', 'read')
            show_partial { Masterfiles::Fruit::StdFruitSizeCount::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          response['Content-Type'] = 'application/json'
          res = interactor.update_std_fruit_size_count(id, params[:std_fruit_size_count])
          if res.success
            update_grid_row(id, changes: { commodity_id: res.instance[:commodity_id], size_count_description: res.instance[:size_count_description], marketing_size_range_mm: res.instance[:marketing_size_range_mm], marketing_weight_range: res.instance[:marketing_weight_range], size_count_interval_group: res.instance[:size_count_interval_group], size_count_value: res.instance[:size_count_value], minimum_size_mm: res.instance[:minimum_size_mm], maximum_size_mm: res.instance[:maximum_size_mm], average_size_mm: res.instance[:average_size_mm], minimum_weight_gm: res.instance[:minimum_weight_gm], maximum_weight_gm: res.instance[:maximum_weight_gm], average_weight_gm: res.instance[:average_weight_gm] },
                            notice:  res.message)
          else
            content = show_partial { Masterfiles::Fruit::StdFruitSizeCount::Edit.call(id, params[:std_fruit_size_count], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          response['Content-Type'] = 'application/json'
          res = interactor.delete_std_fruit_size_count(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'std_fruit_size_counts' do
      interactor = StdFruitSizeCountInteractor.new(current_user, {}, {}, {})
      r.on 'new' do    # NEW
        if authorised?('fruit', 'new')
          show_partial_or_page(fetch?(r)) { Masterfiles::Fruit::StdFruitSizeCount::New.call(remote: fetch?(r)) }
        else
          fetch?(r) ? dialog_permission_error : show_unauthorised
        end
      end
      r.post do        # CREATE
        res = interactor.create_std_fruit_size_count(params[:std_fruit_size_count])
        if res.success
          flash[:notice] = res.message
          if fetch?(r)
            redirect_via_json_to_last_grid
          else
            redirect_to_last_grid(r)
          end
        elsif fetch?(r)
          content = show_partial do
            Masterfiles::Fruit::StdFruitSizeCount::New.call(form_values: params[:std_fruit_size_count],
                                                            form_errors: res.errors,
                                                                remote: true)
          end
          update_dialog_content(content: content, error: res.message)
        else
          flash[:error] = res.message
          show_page do
            Masterfiles::Fruit::StdFruitSizeCount::New.call(form_values: params[:std_fruit_size_count],
                                                            form_errors: res.errors,
                                                            remote: false)
          end
        end
      end
    end
    # TARGET MARKET GROUP TYPES
    # --------------------------------------------------------------------------
    r.on 'target_market_group_types', Integer do |id|
      interactor = TargetMarketGroupTypeInteractor.new(current_user, {}, {}, {})

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
          res = interactor.update_target_market_group_type(id, params[:target_market_group_type])
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
          res = interactor.delete_target_market_group_type(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'target_market_group_types' do
      interactor = TargetMarketGroupTypeInteractor.new(current_user, {}, {}, {})
      r.on 'new' do    # NEW
        if authorised?('fruit', 'new')
          show_partial_or_page(fetch?(r)) { Masterfiles::Fruit::TargetMarketGroupType::New.call(remote: fetch?(r)) }
        else
          fetch?(r) ? dialog_permission_error : show_unauthorised
        end
      end
      r.post do        # CREATE
        res = interactor.create_target_market_group_type(params[:target_market_group_type])
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
      interactor = TargetMarketGroupInteractor.new(current_user, {}, {}, {})

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
          res = interactor.update_target_market_group(id, params[:target_market_group])
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
          res = interactor.delete_target_market_group(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'target_market_groups' do
      interactor = TargetMarketGroupInteractor.new(current_user, {}, {}, {})
      r.on 'new' do    # NEW
        if authorised?('fruit', 'new')
          show_partial_or_page(fetch?(r)) { Masterfiles::Fruit::TargetMarketGroup::New.call(remote: fetch?(r)) }
        else
          fetch?(r) ? dialog_permission_error : show_unauthorised
        end
      end
      r.post do        # CREATE
        res = interactor.create_target_market_group(params[:target_market_group])
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
