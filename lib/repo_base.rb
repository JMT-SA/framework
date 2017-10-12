class RepoBase
  attr_reader :main_table_name, :wrapper, :select_options

  def initialize
    @main_table_name = nil
    @wrapper = nil
    @select_options = {}
  end

  def main_table(value)
    @main_table_name = value
  end

  def table_wrapper(value)
    @wrapper = value
  end

  def for_select_options(value = {})
    @select_options = value
  end

  def all
    raise Crossbeams::FrameworkError, "#{self.class.name}: Cannot call 'all' on a repo that was not initialized with a wrapper. Use a wrapper or 'all_hash'." if wrapper.nil?
    DB[main_table_name].map { |r| wrapper.new(r) }
  end

  def all_hash
    DB[main_table_name].all
  end

  def find!(id)
    raise Crossbeams::FrameworkError, "#{self.class.name}: Cannot call 'find!' on a repo that was not initialized with a wrapper. Use a wrapper or 'find_hash'." if wrapper.nil?
    hash = find_hash(id)
    raise Crossbeams::FrameworkError, "#{self.class.name}: id #{id} not found." if hash.nil?
    wrapper.new(hash)
  end

  def find(id)
    raise Crossbeams::FrameworkError, "#{self.class.name}: Cannot call 'find' on a repo that was not initialized with a wrapper. Use a wrapper or 'find_hash'." if wrapper.nil?
    hash = find_hash(id)
    return nil if hash.nil?
    # wrapper.new(DB[main_table_name].where(id: id).first)
    wrapper.new(hash)
  end

  def find_hash(id)
    DB[main_table_name].where(id: id).first
  end

  def create(attrs)
    DB[main_table_name].insert(attrs.to_h)
  end

  def update(id, attrs)
    DB[main_table_name].where(id: id).update(attrs.to_h)
  end

  def delete(id)
    DB[main_table_name].where(id: id).delete
  end

  def select_values(query)
    DB[query].select_map
  end

  # List of rows for use in a select dropdown.
  # Uses for_select_options to configure.
  # @return Array - list of label/value pairs or just of values.
  def for_select
    label = select_options[:label] || select_options[:value]
    value = select_options[:value]

    dataset = DB[main_table_name]
    if select_options[:order_by]
      dataset = if select_options[:desc]
                  dataset.order_by(Sequel.desc(select_options[:order_by]))
                else
                  dataset.order_by(select_options[:order_by])
                end
    end
    if label == value
      dataset.map { |rec| rec[value] }
    else
      dataset.map { |rec| [rec[label], rec[value]] }
    end
  end
end
