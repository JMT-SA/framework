# frozen_string_literal: true

class Framework < Roda
  route 'grids', 'development' do |r|
    # LISTS
    # --------------------------------------------------------------------------
    r.on 'lists' do
      r.is do
        show_page { Development::Grids::List::List.call }
      end

      grid_interactor = DevelopmentApp::GridInteractor.new(current_user, {}, { route_url: request.path }, {})

      r.on 'grid' do
        return_json_response
        grid_interactor.list_grids.to_json
      end

      r.on 'edit', String do |list_file|
        # view(inline: "GOT #{list_file} for EDIT<p>#{Development::GridInteractor.new(current_user, {}, { route_url: request.path }, {}).list_definition(list_file).inspect}</p>")
        # Build grids for: controls, actions, multiselects, conditions
        list_def = grid_interactor.list_definition(list_file)
        show_page { Development::Grids::List::Edit.call(list_file, list_def) }
      end

      r.on 'grid_actions', String do |list_file|
        return_json_response
        grid_interactor.grid_actions(list_file).to_json
      end

      r.on 'grid_page_controls', String do |list_file|
        return_json_response
        grid_interactor.grid_page_controls(list_file).to_json
      end

      r.on 'grid_multiselects', String do |list_file|
        return_json_response
        grid_interactor.grid_multiselects(list_file).to_json
      end

      r.on 'grid_conditions', String do |list_file|
        return_json_response
        grid_interactor.grid_conditions(list_file).to_json
      end
    end

    r.on 'grid_page_controls', String, Integer do |list_file, index|
      grid_interactor = DevelopmentApp::GridInteractor.new(current_user, {}, { route_url: request.path }, {})

      r.patch do
        res = grid_interactor.update_page_control(params[:page_control])
        update_grid_row(index, changes: { text: res.instance[:text],
                                          url: res.instance[:url],
                                          control_type: res.instance[:control_type],
                                          style: res.instance[:style],
                                          behaviour: res.instance[:behaviour] },
                               notice: res.message)
      end

      res = grid_interactor.page_control(list_file, index)
      show_partial { Development::Grids::PageControl::Edit.call(res) }
    end
  end
end
