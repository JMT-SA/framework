# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestCommodityInteractor < MiniTestWithHooks
    include CommodityFactory

    def test_repo
      repo = interactor.send(:repo)
      assert repo.is_a?(MasterfilesApp::CommodityRepo)
    end

    def test_commodity
      MasterfilesApp::CommodityRepo.any_instance.stubs(:find_commodity).returns(fake_commodity)
      entity = interactor.send(:commodity, 1)
      assert entity.is_a?(Commodity)
    end

    def test_create
      attrs = fake_commodity.to_h.reject { |k, _| k == :id }
      res = interactor.create_commodity(attrs)
      assert res.success, "#{res.message} : #{res.errors.inspect}"
      assert_instance_of(Commodity, res.instance)
      assert res.instance.id.nonzero?
    end

    def test_create_fail
      attrs = fake_commodity(code: nil).to_h.reject { |k, _| k == :id }
      res = interactor.create_commodity(attrs)
      refute res.success, 'should fail validation'
      assert_equal ['must be filled'], res.errors[:code]
    end

    def test_update
      id = create_commodity
      attrs = interactor.send(:repo).find_hash(:commodities, id).reject { |k, _| k == :id }
      value = attrs[:code]
      attrs[:code] = 'a_change'
      res = interactor.update_commodity(id, attrs)
      assert res.success, "#{res.message} : #{res.errors.inspect}"
      assert_instance_of(Commodity, res.instance)
      assert_equal 'a_change', res.instance.code
      refute_equal value, res.instance.code
    end

    def test_update_fail
      id = create_commodity
      attrs = interactor.send(:repo).find_hash(:commodities, id).reject { |k, _| %i[id code].include?(k) }
      value = attrs[:description]
      attrs[:description] = 'a_change'
      res = interactor.update_commodity(id, attrs)
      refute res.success, "#{res.message} : #{res.errors.inspect}"
      assert_equal ['is missing'], res.errors[:code]
      after = interactor.send(:repo).find_hash(:commodities, id)
      refute_equal 'a_change', after[:description]
      assert_equal value, after[:description]
    end

    def test_delete
      id = create_commodity
      assert_count_changed(:commodities, -1) do
        res = interactor.delete_commodity(id)
        assert res.success, res.message
      end
    end

    private

    def commodity_attrs
      commodity_group_id = create_commodity_group
      {
        id: 1,
        commodity_group_id: commodity_group_id,
        code: Faker::Lorem.unique.word,
        description: 'ABC',
        hs_code: 'ABC',
        active: true
      }
    end

    def fake_commodity(overrides = {})
      Commodity.new(commodity_attrs.merge(overrides))
    end

    def interactor
      @interactor ||= CommodityInteractor.new(current_user, {}, {}, {})
    end
  end
end
