# frozen_string_literal: true

class Framework < Roda
  route 'logging', 'development' do |r|
    #
    # LOGGED ACTION DETAILS
    # --------------------------------------------------------------------------
    r.on 'logged_actions', Integer do |id|
      interactor = DevelopmentApp::LoggingInteractor.new(current_user, {}, {}, {})

      # Check for notfound:
      r.on !interactor.exists?(Sequel[:audit][:logged_actions], id) do
        handle_not_found(r)
      end

      r.is do
        r.get do       # SHOW
          if authorised?('logging', 'read')
            # using id of logged_action, build a grid of changes.
            show_page { Development::Logging::LoggedAction::Show.call(id) }
          else
            show_unauthorised
          end
        end
      end

      r.on 'grid' do
        response['Content-Type'] = 'application/json'
        interactor.logged_actions_grid(id)
      end
    end
  end
end
