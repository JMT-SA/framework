# frozen_string_literal: true

module PackMaterialApp
  class ERPPurchaseInvoiceJob < BaseQueJob
    def run(user_name, delivery_id: nil)
      repo = BaseRepo.new
      raise Crossbeams::FrameworkError 'Delivery ID is null' unless delivery_id
      repo.transaction do
        PackMaterialApp::CompletePurchaseInvoice.call(user_name, delivery_id)
        finish
      end
    end
  end
end
