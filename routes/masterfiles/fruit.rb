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
        rescue => e
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
          rescue => e
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
        rescue => e
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
        rescue => e
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
          rescue => e
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
        rescue => e
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
  end
end
