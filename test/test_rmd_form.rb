require File.join(File.expand_path('./../', __FILE__), 'test_helper')

class TestRMDForm < Minitest::Test

  def make_form(details = {}, options = {})
    opts = {
      form_name: :rmd_form,
      action: '/post_me'
    }
    form = Crossbeams::RMDForm.new(details, opts.merge(options))
    form.add_csrf_tag('abc')
    form
  end

  def test_numeric_with_decimals
    form = make_form
    form.add_field('test', 'Test', data_type: 'number', allow_decimals: true)
    assert_match(/type="number" step="any"/, form.render)

    form = make_form
    form.add_field('test', 'Test', data_type: 'number')
    assert_match(/type="number"/, form.render)
    refute_match(/type="number" step="any"/, form.render)
  end

  def test_no_submit
    form = make_form
    form.add_field('test', 'Test', data_type: 'text')
    assert_match(/type="submit"/, form.render)

    form = make_form({}, action: nil, no_submit: true)
    form.add_field('test', 'Test', data_type: 'text')
    refute_match(/type="submit"/, form.render)
  end

  def test_submit_dom_id
    form = make_form
    refute_match(/id="the-submit-button"/, form.render)

    form = make_form({}, action: nil, button_id: 'the-submit-button')
    assert_match(/id="the-submit-button"/, form.render)
  end

  def test_hide_submit
    form = make_form
    assert_match(/data-rmd-btn="Y">/, form.render)

    form = make_form({}, action: nil, button_initially_hidden: true)
    assert_match(/data-rmd-btn="Y" hidden>/, form.render)
  end

  def test_section_header
    form = make_form
    form.add_section_header('test')
    assert_match(/>test<\/td/, form.render)
    assert_match(/id="sh_#{'test'.hash}"/, form.render)

    form = make_form
    form.add_section_header('test', id: 'this_id_instead')
    refute_match(/id="sh_#{'test'.hash}"/, form.render)
    assert_match(/id="this_id_instead"/, form.render)
  end

  def test_hide_on_load
    form = make_form
    form.add_section_header('test')
    refute_match(/<tr id=".+ hidden>/, form.render)

    form = make_form
    form.add_section_header('test', hide_on_load: true)
    assert_match(/<tr id=".+ hidden>/, form.render)

    form = make_form
    form.add_field('test', 'Test', {})
    refute_match(/<tr id=".+ hidden>/, form.render)

    form = make_form
    form.add_field('test', 'Test', hide_on_load: true)
    assert_match(/<tr id=".+ hidden>/, form.render)

    form = make_form
    form.add_label('test', 'Test', 'abc')
    refute_match(/<tr id=".+ hidden>/, form.render)

    form = make_form
    form.add_label('test', 'Test', 'abc', nil, hide_on_load: true)
    assert_match(/<tr id=".+ hidden>/, form.render)

    form = make_form
    form.add_select('test', 'Test', {})
    refute_match(/<tr id=".+ hidden>/, form.render)

    form = make_form
    form.add_select('test', 'Test', hide_on_load: true)
    assert_match(/<tr id=".+ hidden>/, form.render)

    form = make_form
    form.add_toggle('test', 'Test')
    refute_match(/<tr id=".+ hidden>/, form.render)

    form = make_form
    form.add_toggle('test', 'Test', hide_on_load: true)
    assert_match(/<tr id=".+ hidden>/, form.render)
  end

  def test_toggle
    form = make_form
    form.add_toggle(:test, 'Test')
    assert_match(/<input type="checkbox"/, form.render)
    assert_match(/value="t">/, form.render)

    form = make_form(test: 't')
    form.add_toggle(:test, 'Test')
    assert_match(/<input type="checkbox"/, form.render)
    assert_match(/value="t" checked>/, form.render)
  end

  def test_label_classes
    form = make_form
    form.add_label('test', 'Test', 'abc')
    assert_match(/<div class="pa2 bg-moon-gray br2"/, form.render)

    form = make_form
    form.add_label('test', 'Test', 'abc', nil, value_class: 'red')
    assert_match(/<div class="red pa2 bg-moon-gray br2"/, form.render)

    form = make_form
    form.add_label('test', 'Test', 'abc', nil, as_table_cell: true)
    refute_match(/<div class="pa2 bg-moon-gray br2"/, form.render)

    form = make_form
    form.add_label('test', 'Test', 'abc', nil, as_table_cell: true, value_class: 'red')
    assert_match(/<div class="red"/, form.render)
  end
end
