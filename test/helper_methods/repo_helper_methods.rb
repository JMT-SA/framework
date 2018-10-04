# frozen_string_literal: true

module RepoHelperMethods
  def around
    DB.transaction(rollback: :always, savepoint: true, auto_savepoint: true) do
      super
    end
  end

  def around_all
    DB.transaction(rollback: :always) do
      # Run all the seed-creation methods:
      @fixed_table_set = {}
      methods.grep(/^db_create_.+/).each { |m| send(m) }
      super
    end
  rescue StandardError => e
    p e
    raise "Display possible around errors"
  end

  def test_crud_calls_for(table_name, options = {}) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize
    name    = options[:name] || table_name
    wrapper = options[:wrapper]
    skip    = options[:exclude] || []

    repo = self.send(:repo)
    unless wrapper.nil?
      define_method(:"test_find_#{name}") do
        assert_respond_to repo, :"find_#{name}"
      end
    end

    unless skip.include?(:create)
      define_method(:"test_create_#{name}") do
        assert_respond_to repo, :"create_#{name}"
      end
    end

    unless skip.include?(:update)
      define_method(:"test_update_#{name}") do
        assert_respond_to repo, :"update_#{name}"
      end
    end

    return if skip.include?(:delete)
    define_method(:"test_delete_#{name}") do
      assert_respond_to repo, :"delete_#{name}"
    end
  end
end