class RepoBase
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

  def where(table_name, wrapper, args)
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
    dataset.select(value_name).map { |rec| rec[value_name] }
  end

  def select_two(dataset, label_name, value_name)
    if label_name.is_a?(Array)
      dataset.select(*label_name, value_name).map { |rec| [label_name.map { |nm| rec[nm] }.join(' - '), rec[value_name]] }
    else
      dataset.select(label_name, value_name).map { |rec| [rec[label_name], rec[value_name]] }
    end
  end

  # Helper to convert a Ruby Hash into a string that postgresql will understand.
  def hash_to_jsonb_str(hash)
    "{#{hash.map { |k, v| %("#{k}":"#{v}") }.join(',')}}"
  end

  def self.inherited(klass)
    klass.extend(MethodBuilder)
  end
end

module MethodBuilder
  # Define a +for_select_table_name+ method in a repo.
  # The method returns an array of values for use in e.g. a select dropdown.
  # Options:
  # alias: String
  # - If present, will be named +for_select_alias+ instead of +for_select_table_name+.
  # label: String or Array
  # - The display column. Defaults to the value column. If an Array, will display each column separated by ' - '
  # value: String
  # - The value column. Required.
  # order_by: String
  # - The column to order by.
  # desc: Boolean
  # - Use descending order if this option is present and truthy.
  # no_activity_check: Boolean
  # - Set to true if this table does not have an +active+ column,
  #   or to return inactive records as well as active ones.
  def build_for_select(table_name, options = {})
    define_method(:"for_select_#{options[:alias] || table_name}") do |opts = {}|
      dataset = DB[table_name]
      dataset = make_order(dataset, options) if options[:order_by]
      dataset = dataset.where(:active) unless options[:no_active_check]
      dataset = dataset.where(opts[:where]) if opts[:where]
      lbl = options[:label] || options[:value]
      val = options[:value]
      lbl == val ? select_single(dataset, val) : select_two(dataset, lbl, val)
    end
  end

  # Define a +for_select_inactive_table_name+ method in a repo.
  # The method returns an array of values from inactive rows for use in e.g. a select dropdown's +disabled_options+.
  # Options:
  # alias: String
  # - If present, will be named +for_select_alias+ instead of +for_select_table_name+.
  # label: String or Array
  # - The display column. Defaults to the value column. If an Array, will display each column separated by ' - '
  # value: String
  # - The value column. Required.
  def build_inactive_select(table_name, options = {})
    define_method(:"for_select_inactive_#{options[:alias] || table_name}") do
      dataset = DB[table_name].exclude(:active)
      lbl = options[:label] || options[:value]
      val = options[:value]
      lbl == val ? select_single(dataset, val) : select_two(dataset, lbl, val)
    end
  end

  # Define CRUD methods for a table in a repo.
  # Call like this: +crud_calls_for+ :table_name.
  # This creates find_name, create_name, update_name and delete_name methods for the repo.
  # There are 2 optional params.
  #
  #     crud_calls_for :table_name, name: :table, wrapper: Table
  #
  # This produces the following methods:
  #
  #     find_table(id)
  #     create_table(attrs)
  #     update_table(id, attrs)
  #     delete_table(id)
  #
  # Options:
  # name: String
  # - Change the name portion of the method. default: table_name.
  # wrapper: Class
  # - The wrapper class. If not provided, there will be no +find_+ method.
  def crud_calls_for(table_name, options = {})
    name    = options[:name] || table_name
    wrapper = options[:wrapper]

    unless wrapper.nil?
      define_method(:"find_#{name}") do |id|
        find(table_name, wrapper, id)
      end
    end

    define_method(:"create_#{name}") do |attrs|
      create(table_name, attrs)
    end

    define_method(:"update_#{name}") do |id, attrs|
      update(table_name, id, attrs)
    end

    define_method(:"delete_#{name}") do |id|
      delete(table_name, id)
    end
  end
end
