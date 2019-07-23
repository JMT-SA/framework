# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestCommodityGroupInteractor < MiniTestWithHooks
    include CommodityFactory

    def test_repo
      repo = interactor.send(:repo)
      assert repo.is_a?(MasterfilesApp::CommodityRepo)
    end

    def test_commodity_group
      MasterfilesApp::CommodityRepo.any_instance.stubs(:find_commodity_group).returns(fake_commodity_group)
      entity = interactor.send(:commodity_group, 1)
      assert entity.is_a?(CommodityGroup)
    end

    def test_create
      attrs = fake_commodity_group.to_h.reject { |k, _| k == :id }
      res = interactor.create_commodity_group(attrs)
      assert res.success, "#{res.message} : #{res.errors.inspect}"
      assert_instance_of(CommodityGroup, res.instance)
      assert res.instance.id.nonzero?
    end

    def test_create_fail
      attrs = fake_commodity_group(code: nil).to_h.reject { |k, _| k == :id }
      res = interactor.create_commodity_group(attrs)
      refute res.success, 'should fail validation'
      assert_equal ['must be filled'], res.errors[:code]
    end

    def test_update
      id = create_commodity_group
      attrs = interactor.send(:repo).find_hash(:commodity_groups, id).reject { |k, _| k == :id }
      value = attrs[:code]
      attrs[:code] = 'a_change'
      res = interactor.update_commodity_group(id, attrs)
      assert res.success, "#{res.message} : #{res.errors.inspect}"
      assert_instance_of(CommodityGroup, res.instance)
      assert_equal 'a_change', res.instance.code
      refute_equal value, res.instance.code
    end

    def test_update_fail
      id = create_commodity_group
      attrs = interactor.send(:repo).find_hash(:commodity_groups, id).reject { |k, _| %i[id code].include?(k) }
      value = attrs[:description]
      attrs[:description] = 'a_change'
      res = interactor.update_commodity_group(id, attrs)
      refute res.success, "#{res.message} : #{res.errors.inspect}"
      assert_equal ['is missing'], res.errors[:code]
      after = interactor.send(:repo).find_hash(:commodity_groups, id)
      refute_equal 'a_change', after[:description]
      assert_equal value, after[:description]
    end

    def test_delete
      id = create_commodity_group
      assert_count_changed(:commodity_groups, -1) do
        res = interactor.delete_commodity_group(id)
        assert res.success, res.message
      end
    end

    # New scaffold form to ask for shared factory..

    private

    def commodity_group_attrs
      {
        id: 1,
        code: Faker::Lorem.unique.word,
        description: 'ABC',
        active: true
      }
    end

    def fake_commodity_group(overrides = {})
      CommodityGroup.new(commodity_group_attrs.merge(overrides))
    end

    def interactor
      @interactor ||= CommodityInteractor.new(current_user, {}, {}, {})
    end
  end
end
