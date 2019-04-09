# frozen_string_literal: true

require 'drb/drb'

module LabelApp
  class SharedConfigRepo
    include Crossbeams::Responses

    def packmat_labels_config
      @packmat_labels_config ||= remote_object_packmat_config
    end

    def remote_object_config_for(variable_set)
      DRb.start_service
      remote_object = DRbObject.new_with_uri("druby://#{AppConst::SHARED_CONFIG_HOST_PORT}")
      res = remote_object.config_for(variable_set)
      DRb.stop_service
      res
    rescue DRb::DRbConnError => e
      DRb.stop_service
      msg = if e.cause
              e.cause.message
            else
              e.message
            end
      raise Crossbeams::FrameworkError, "The Shared config is not reachable at #{AppConst::SHARED_CONFIG_HOST_PORT} : #{msg}"
    end

    def remote_object_packmat_config
      remote_object_config_for('Pack Material')
    end

    def remote_object_variable_groups(key)
      DRb.start_service
      remote_object = DRbObject.new_with_uri("druby://#{AppConst::SHARED_CONFIG_HOST_PORT}")
      res = remote_object.grouped_names(key)
      DRb.stop_service
      res
    rescue DRb::DRbConnError => e
      DRb.stop_service
      msg = if e.cause
              e.cause.message
            else
              e.message
            end
      raise Crossbeams::FrameworkError, "The Shared config is not reachable at #{AppConst::SHARED_CONFIG_HOST_PORT} : #{msg}"
    end
  end
end
