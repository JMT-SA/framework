# frozen_string_literal: true

require 'drb/drb'

module LabelApp
  class SharedConfigRepo
    include Crossbeams::Responses

    def packmat_labels_config
      @packmat_labels_config ||= begin
                                   DRb.start_service
                                   remote_object = DRbObject.new_with_uri("druby://#{AppConst::SHARED_CONFIG_HOST_PORT}")
                                   remote_object.config_for(:packmat)
                                 end
    end
  end
end
