# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/BlockLength

class Framework < Roda
  route 'transactions', 'pack_material' do |r|
    # ADHOC STOCK TRANSACTIONS
    # --------------------------------------------------------------------------
    r.on 'adhoc_stock_transactions', Integer do |id|
      interactor = PackMaterialApp::MrInventoryTransactionInteractor.new(current_user, {}, { route_url: request.path }, {})
      # Check for notfound:
      r.on !interactor.exists?(:mr_sku_locations, id) do
        handle_not_found(r)
      end

      r.on 'add' do
        check_auth!('transactions', 'new')
        show_partial_or_page(r) { PackMaterial::Transactions::MrInventoryTransaction::New.call(id, type: 'add', remote: fetch?(r)) }
      end
      r.on 'move' do
        check_auth!('transactions', 'new')
        show_partial_or_page(r) { PackMaterial::Transactions::MrInventoryTransaction::New.call(id, type: 'move', remote: fetch?(r)) }
      end
      r.on 'remove' do
        check_auth!('transactions', 'new')
        show_partial_or_page(r) { PackMaterial::Transactions::MrInventoryTransaction::New.call(id, type: 'remove', remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_adhoc_stock_transaction(id, params[:mr_inventory_transaction], params[:type])
        if res.success
          show_json_notice(res.message)
        else
          re_show_form(r, res, url: "/pack_material/transactions/adhoc_stock_transactions/#{id}/#{params[:type]}") do
            PackMaterial::Transactions::MrInventoryTransaction::New.call(id,
                                                                         type: params[:type],
                                                                         form_values: params[:mr_inventory_transaction],
                                                                         form_errors: res.errors,
                                                                         remote: fetch?(r))
          end
        end
      end
      # UNDO link in success message
      # r.is do
      #   r.get do
      #     check_auth!('transactions', 'read')
      #     show_partial { PackMaterial::Transactions::MrInventoryTransaction::Result.call(id) }
      #   end
      # end
    end
  end
end

# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/BlockLength
