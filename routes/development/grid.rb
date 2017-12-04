# frozen_string_literal: true

class Framework < Roda
  route 'grids', 'development' do |r|
    # LISTS
    # --------------------------------------------------------------------------
    r.on 'lists' do
      r.is do
        show_page { Development::Grids::List::List.call }
      end

      grid_interactor = GridInteractor.new(current_user, {}, {}, {})

      r.on 'grid' do
        response['Content-Type'] = 'application/json'
        grid_interactor.list_grids.to_json
      end

      r.on 'edit', String do |list_file|
        # view(inline: "GOT #{list_file} for EDIT<p>#{GridInteractor.new(current_user, {}, {}, {}).list_definition(list_file).inspect}</p>")
        # Build grids for: controls, actions, multiselects, conditions
        list_def = grid_interactor.list_definition(list_file)
        show_page { Development::Grids::List::Edit.call(list_file, list_def) }
      end

      r.on 'grid_actions', String do |list_file|
        response['Content-Type'] = 'application/json'
        grid_interactor.grid_actions(list_file).to_json
      end

      r.on 'grid_page_controls', String do |list_file|
        response['Content-Type'] = 'application/json'
        grid_interactor.grid_page_controls(list_file).to_json
      end

      r.on 'grid_multiselects', String do |list_file|
        response['Content-Type'] = 'application/json'
        grid_interactor.grid_multiselects(list_file).to_json
      end

      r.on 'grid_conditions', String do |list_file|
        response['Content-Type'] = 'application/json'
        grid_interactor.grid_conditions(list_file).to_json
      end
    end
  end
end
