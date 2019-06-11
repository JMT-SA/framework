# frozen_string_literal: true

module PackMaterialApp
  class ERPPurchaseInvoiceJob < BaseQueJob
    def run(user_name, delivery_id: nil)
      raise Crossbeams::FrameworkError 'Delivery ID is null' unless delivery_id
      PackMaterialApp::CompletePurchaseInvoice.call(user_name, delivery_id) { finish }
    end
  end
end
