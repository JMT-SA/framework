# frozen_string_literal: true

class Framework < Roda
  route 'logging', 'development' do |r|
    #
    # LOGGED ACTION DETAILS
    # --------------------------------------------------------------------------
    r.on 'logged_actions', Integer do |id|
      interactor = DevelopmentApp::LoggingInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(Sequel[:audit][:logged_actions], id) do
        handle_not_found(r)
      end

      r.is do
        r.get do       # SHOW
          raise Crossbeams::AuthorizationError unless authorised?('logging', 'read')
          # using id of logged_action, build a grid of changes.
          show_page { Development::Logging::LoggedAction::Show.call(id) }
        end
      end

      r.on 'grid' do
        return_json_response
        interactor.logged_actions_grid(id)
      end

      r.on 'diff' do
        left, right = interactor.diff_action(id)
        show_partial { Development::Logging::LoggedAction::Diff.call(id, left, right) }
      end
    end
  end
end
