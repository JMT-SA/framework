# frozen_string_literal: true

class Framework < Roda
  route 'generators', 'development' do |r|
    # SCAFFOLDS
    # --------------------------------------------------------------------------
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
