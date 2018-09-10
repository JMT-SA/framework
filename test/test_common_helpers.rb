require File.join(File.expand_path('./../', __FILE__), 'test_helper')

class TestCommonHelpers < Minitest::Test
  include CommonHelpers

  def test_select_attributes
    instance = { one: 1, two: 2 }
    row_keys = %i[one two]
    assert_equal instance, select_attributes(instance, row_keys)
    assert_equal({ one: 1, two: 2, three: 3 }, select_attributes(instance, row_keys, three: 3))
    assert_equal({ one: 1, two: 22, three: 3 }, select_attributes(instance, row_keys, three: 3, two: 22))
  end

  def test_base_validation
    assert_equal({ base: ['Err'] }, add_base_validation_errors({}, 'Err'))
    assert_equal({ fld1: ['must be filled'], base: ['Err'] }, add_base_validation_errors({fld1: ['must be filled']}, 'Err'))
    assert_equal({ base: ['Err-1', 'Err-2'] }, add_base_validation_errors({}, ['Err-1', 'Err-2']))
  end

  def test_base_validation_with_highlights
    assert_equal({ base_with_highlights: { messages: ['Err'], highlights: :fld1 } },
                 add_base_validation_errors_with_highlights({}, 'Err', :fld1))
    assert_equal({ fld1: ['must be filled'], base_with_highlights: { messages: ['Err'], highlights: [:fld1, :fld2] } },
                 add_base_validation_errors_with_highlights({fld1: ['must be filled']}, 'Err', [:fld1, :fld2]))
    assert_equal({ base_with_highlights: { messages: ['Err-1', 'Err-2'], highlights: :fld1 } },
                 add_base_validation_errors_with_highlights({}, ['Err-1', 'Err-2'], :fld1))
  end

  def test_load_via_json
    plain = { loadNewUrl: '/test' }.to_json
    with_notice = { loadNewUrl: '/test', flash: {notice: 'NOTE' } }.to_json
    assert_equal plain, load_via_json('/test')
    assert_equal with_notice, load_via_json('/test', notice: 'NOTE')
  end

  def test_reload_previous_dialog_via_json
    plain = { reloadPreviousDialog: '/test' }.to_json
    with_notice = { reloadPreviousDialog: '/test', flash: {notice: 'NOTE' } }.to_json
    assert_equal plain, reload_previous_dialog_via_json('/test')
    assert_equal with_notice, reload_previous_dialog_via_json('/test', notice: 'NOTE')
  end
end
