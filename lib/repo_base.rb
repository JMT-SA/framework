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
    all_hash.map { |r| wrapper.new(r) }
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
    wrapper.new(hash)
  end

  def find_hash(id)
    where_hash(id: id)
  end

  def where(args)
    raise Crossbeams::FrameworkError, "#{self.class.name}: Cannot call 'where' on a repo that was not initialized with a wrapper. Use a wrapper or 'where_hash'." if wrapper.nil?
    hash = where_hash(args)
    return nil if hash.nil?
    wrapper.new(hash)
  end

  def where_hash(args)
    DB[main_table_name].where(args).first
  end

  def exists?(args)
    DB.select(1).where(DB[main_table_name].where(args).exists).one?
  end

  def row_exists?(table_name, args)
    DB.select(1).where(DB[table_name].where(args).exists).one?
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
    dataset = DB[main_table_name]
    dataset = make_order(dataset) if select_options[:order_by]
    select_label_name == select_value_name ? select_single(dataset) : select_two(dataset)
  end

  def select_single(dataset)
    dataset.map { |rec| rec[select_value_name] }
  end

  def select_two(dataset)
    dataset.map { |rec| [rec[select_label_name], rec[select_value_name]] }
  end

  def select_label_name
    @sel_label_name ||= select_options[:label] || select_options[:value]
  end

  def select_value_name
    @sel_value_name ||= select_options[:value]
  end

  def make_order(dataset)
    if select_options[:desc]
      dataset.order_by(Sequel.desc(select_options[:order_by]))
    else
      dataset.order_by(select_options[:order_by])
    end
  end
end
