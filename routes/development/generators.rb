# frozen_string_literal: true

class Framework < Roda
  route 'generators', 'development' do |r|

    # SCAFFOLDS
    # --------------------------------------------------------------------------
    # r.on 'scaffolds', Integer do |id|
    #   repo                = CommodityGroupRepo.new
    #   commodity_group = repo.find(id)
    #
    #   # Check for notfound:
    #   r.on commodity_group.nil? do
    #     handle_not_found(r)
    #   end
    #
    #   r.on 'edit' do   # EDIT
    #     begin
    #       if authorised?('menu', 'edit')
    #         show_partial { Development::Generators::CommodityGroups::Edit.call(id) }
    #       else
    #         dialog_permission_error
    #       end
    #     rescue => e
    #       dialog_error(e)
    #     end
    #   end
    #   r.is do
    #     r.get do       # SHOW
    #       if authorised?('menu', 'read')
    #         show_partial { Development::Generators::CommodityGroups::Show.call(id) }
    #       else
    #         dialog_permission_error
    #       end
    #     end
    #     r.patch do     # UPDATE
    #       begin
    #         response['Content-Type'] = 'application/json'
    #         res = CommodityGroupSchema.call(params[:commodity_group])
    #         errors = res.messages
    #         if errors.empty?
    #           repo = CommodityGroupRepo.new
    #           repo.update(id, res)
    #           # flash[:notice] = 'Updated'
    #           # redirect_via_json_to_last_grid
    #           update_grid_row(id, changes: { code: res[:code], description: res[:description] },
    #                               notice:  "Updated #{res[:code]}")
    #         else
    #           content = show_partial { Development::Generators::CommodityGroups::Edit.call(id, params[:commodity_group], errors) }
    #           update_dialog_content(content: content, error: 'Validation error')
    #         end
    #       rescue => e
    #         handle_json_error(e)
    #       end
    #     end
    #     r.delete do    # DELETE
    #       response['Content-Type'] = 'application/json'
    #       repo = CommodityGroupRepo.new
    #       repo.delete(id)
    #       # flash[:notice] = 'Deleted'
    #       # redirect_to_last_grid(r)
    #       delete_grid_row(id, notice: 'Deleted')
    #     end
    #   end
    # end
    r.on 'scaffolds' do
      r.on 'new' do    # NEW
        begin
          # if authorised?('menu', 'new')
            show_page { Development::Generators::Scaffolds::New.call }
          # else
          #   show_unauthorised
          # end
          # Should lead to step 1, 2 etc.
        rescue => e
          handle_error(e)
        end
      end
      r.post do        # CREATE
        res = ScaffoldNewSchema.call(params[:scaffold] || {})
        errors = res.messages
        if errors.empty?
          result = GenerateNewScaffold.call(params[:scaffold])
          # puts result[:repo]
          # puts result[:entity]
          show_page { Development::Generators::Scaffolds::Show.call(result) }
          # if ok
          # redirect
          # else
          # re-show page
          # end
          #
          # call service
          # repo = CommodityGroupRepo.new
          # repo.create(res)
          # flash[:notice] = 'Created'
          # redirect_to_last_grid(r)
        else
          puts errors.inspect
          show_page { Development::Generators::Scaffolds::New.call(params[:scaffold], errors) }
        end
      end
    end
  end
end
