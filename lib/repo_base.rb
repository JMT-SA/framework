class RepoBase
  attr_reader :main_table_name, :wrapper, :select_options

  def all(table_name, wrapper)
    all_hash(table_name).map { |r| wrapper.new(r) }
  end

  def all_hash(table_name)
    DB[table_name].all
  end

  def find!(table_name, wrapper, id)
    hash = find_hash(table_name, id)
    raise Crossbeams::FrameworkError, "#{table_name}: id #{id} not found." if hash.nil?
    wrapper.new(hash)
  end

  def find(table_name, wrapper, id)
    hash = find_hash(table_name, id)
    return nil if hash.nil?
    wrapper.new(hash)
  end

  def find_hash(table_name, id)
    where_hash(table_name, id: id)
  end

  def where(table_name, args)
    hash = where_hash(table_name, args)
    return nil if hash.nil?
    wrapper.new(hash)
  end

  def where_hash(table_name, args)
    DB[table_name].where(args).first
  end

  def exists?(table_name, args)
    DB.select(1).where(DB[table_name].where(args).exists).one?
  end

  def create(table_name, attrs)
    DB[table_name].insert(attrs.to_h)
  end

  def update(table_name, id, attrs)
    DB[table_name].where(id: id).update(attrs.to_h)
  end

  def delete(table_name, id)
    DB[table_name].where(id: id).delete
  end

  def select_values(query)
    DB[query].select_map
  end

  def make_order(dataset, sel_options)
    if sel_options[:desc]
      dataset.order_by(Sequel.desc(sel_options[:order_by]))
    else
      dataset.order_by(sel_options[:order_by])
    end
  end

  def select_single(dataset, value_name)
    dataset.map { |rec| rec[value_name] }
  end

  def select_two(dataset, label_name, value_name)
    dataset.map { |rec| [rec[label_name], rec[value_name]] }
  end

  def self.inherited(klass)
    klass.extend(ForSelectBuilder)
  end
end

module ForSelectBuilder
  def build_for_select(table_name, options = {})
    define_method(:"for_select_#{options[:alias] || table_name}") do
      dataset = DB[table_name]
      dataset = make_order(dataset, options) if options[:order_by]
      lbl = options[:label] || options[:value]
      val = options[:value]
      lbl == val ? select_single(dataset, val) : select_two(dataset, lbl, val)
    end
  end
end
