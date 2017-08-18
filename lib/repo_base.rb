class RepoBase
  attr_reader :main_table_name, :wrapper

  def initialize
    @main_table_name = nil
    @wrapper = nil
  end

  def set_main_table(value)
    @main_table_name = value
  end

  def set_wrapper(value)
    @wrapper = value
  end

  def all
    raise Crossbeams::FrameworkError, "#{self.class.name}: Cannot call 'all' on a repo that was not initialized with a wrapper. Use a wrapper or 'all_hash'." if wrapper.nil?
    DB[main_table_name].map { |r| wrapper.new(r) }
  end

  def all_hash
    DB[main_table_name].all
  end

  def find(id)
    raise Crossbeams::FrameworkError, "#{self.class.name}: Cannot call 'find' on a repo that was not initialized with a wrapper. Use a wrapper or 'find_hash'." if wrapper.nil?
    wrapper.new(DB[main_table_name].where(id: id).first)
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
end
