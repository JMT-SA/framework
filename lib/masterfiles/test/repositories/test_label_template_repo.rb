# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestLabelTemplateRepo < MiniTestWithHooks
    def test_for_selects
      assert_respond_to repo, :for_select_label_templates
    end

    def test_crud_calls
      test_crud_calls_for :label_templates, name: :label_template, wrapper: LabelTemplate
    end

    private

    def repo
      LabelTemplateRepo.new
    end
  end
end
