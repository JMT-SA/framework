# frozen_string_literal: true

class Framework < Roda
  route 'logging', 'development' do |r| # rubocop:disable Metrics/BlockLength
    #
    # LOGGED ACTION DETAILS
    # --------------------------------------------------------------------------
    r.on 'logged_actions', Integer do |id|
      interactor = DevelopmentApp::LoggingInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      # r.on !interactor.exists?(Sequel[:audit][:logged_actions], id) do
      #   handle_not_found(r)
      # end

      r.is do
        r.get do       # SHOW
          check_auth!('logging', 'read')
          # using id of logged_action, build a grid of changes.
          show_page { Development::Logging::LoggedAction::Show.call(id) }
        end
      end

      r.on 'grid' do
        interactor.logged_actions_grid(id)
      rescue StandardError => e
        show_json_exception(e)
      end

      r.on 'diff' do
        left, right = interactor.diff_action(id)
        show_partial { Development::Logging::LoggedAction::Diff.call(id, left, right) }
      end

      # Move to status route, but use this interactor...
      r.on 'diff_from_status' do
        left, right = interactor.diff_action(id, from_status_log: true)
        # OR return res with nil & view sorts it out
        # if left.nil?
        #   update_dialog_content(content: 'not found')
        # else
          show_partial { Development::Logging::LoggedAction::Diff.call(id, left, right) }
        # end
      end
    end

    # QUE JOBS
    # --------------------------------------------------------------------------
    r.on 'que_jobs', Integer do |id|
      r.is do
        r.get do       # SHOW
          check_auth!('logging', 'read')
          show_partial { Development::Logging::QueJob::Show.call(id) }
        end
      end
    end

    r.on 'que_jobs' do
      r.on 'status' do
        check_auth!('logging', 'read')
        show_partial_or_page(r) { Development::Logging::QueJob::Status.call }
      end
    end
  end
end
