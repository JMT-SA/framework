class RepoBase
  include Crossbeams::Responses

  # Return all rows from a table as instances of the given wrapper.
  #
  # @param table_name [Symbol] the db table name.
  # @param wrapper [Class] the class of the object to return.
  # @return [Array] the table rows.
  def all(table_name, wrapper)
    all_hash(table_name).map { |r| wrapper.new(r) }
  end

  # Return all rows from a table as Hashes.
  #
  # @param table_name [Symbol] the db table name.
  # @return [Array] the table rows.
  def all_hash(table_name)
    DB[table_name].all
  end

  # Find a row in a table. Raises an exception if it is not found.
  #
  # @param table_name [Symbol] the db table name.
  # @param wrapper [Class] the class of the object to return.
  # @param id [Integer] the id of the row.
  # @return [Object] the row wrapped in a new wrapper object.
  def find!(table_name, wrapper, id)
    hash = find_hash(table_name, id)
    # raise Crossbeams::FrameworkError, "#{table_name}: id #{id} not found." if hash.nil?
    raise "#{table_name}: id #{id} not found." if hash.nil?
    wrapper.new(hash)
  end

  # Find a row in a table. Returns nil if it is not found.
  #
  # @param table_name [Symbol] the db table name.
  # @param wrapper [Class] the class of the object to return.
  # @param id [Integer] the id of the row.
  # @return [Object, nil] the row wrapped in a new wrapper object.
  def find(table_name, wrapper, id)
    hash = find_hash(table_name, id)
    return nil if hash.nil?
    wrapper.new(hash)
  end

  # Find a row in a table. Returns nil if it is not found.
  #
  # @param table_name [Symbol] the db table name.
  # @param id [Integer] the id of the row.
  # @return [Hash, nil] the row as a Hash.
  def find_hash(table_name, id)
    where_hash(table_name, id: id)
  end

  # Find the first row in a table matching some condition.
  # Returns nil if it is not found.
  #
  # @param table_name [Symbol] the db table name.
  # @param wrapper [Class] the class of the object to return.
  # @param args [Hash] the where-clause conditions.
  # @return [Object, nil] the row wrapped in a new wrapper object.
  def where(table_name, wrapper, args)
    hash = where_hash(table_name, args)
    return nil if hash.nil?
    wrapper.new(hash)
  end

  # Find the first row in a table matching some condition.
  # Returns nil if it is not found.
  #
  # @param table_name [Symbol] the db table name.
  # @param args [Hash] the where-clause conditions.
  # @return [Hash, nil] the row as a Hash.
  def where_hash(table_name, args)
    DB[table_name].where(args).first
  end

  # Checks to see if a row exists that meets the given requirements.
  #
  # @param table_name [Symbol] the db table name.
  # @param args [Hash] the where-clause conditions.
  # @return [Boolean] true if the row exists.
  def exists?(table_name, args)
    DB.select(1).where(DB[table_name].where(args).exists).one?
  end

  # Create a record.
  #
  # @param table_name [Symbol] the db table name.
  # @param attrs [Hash, OpenStruct] the fields and their values.
  # @return [Integer] the id of the new record.
  def create(table_name, attrs)
    DB[table_name].insert(attrs.to_h)
  end

  # Update a record.
  #
  # @param table_name [Symbol] the db table name.
  # @param id [Integer] the id of the record.
  # @param attrs [Hash, OpenStruct] the fields and their values.
  def update(table_name, id, attrs)
    DB[table_name].where(id: id).update(attrs.to_h)
  end

  # Delete a record.
  #
  # @param table_name [Symbol] the db table name.
  # @param id [Integer] the id of the record.
  def delete(table_name, id)
    DB[table_name].where(id: id).delete
  end

  # Deactivate a record.
  # Sets the +active+ column to false.
  #
  # @param table_name [Symbol] the db table name.
  # @param id [Integer] the id of the record.
  def deactivate(table_name, id)
    DB[table_name].where(id: id).update(active: false)
  end

  # Run a query returning an array of values from the first column.
  #
  # @param query [String] the SQL query to run.
  # @return [Array] the values from the first column of each row.
  def select_values(query)
    DB[query].select_map
  end

  # Helper to convert a Ruby Hash into a string that postgresql will understand.
  #
  # @param hash [Hash] the hash to convert.
  # @return [String] JSON String version of the Hash.
  def hash_to_jsonb_str(hash)
    "{#{(hash || {}).map { |k, v| %("#{k}":"#{v}") }.join(',')}}"
  end

  # rubocop:disable Metrics/ParameterLists

  # Log the context of an action change on a table row.
  #
  # @param table_name [Symbol] the table name.
  # @param id [Integer] the id of the row.
  # @param action [String] the action (I == insert, D == delete, U == update)
  # @param user_name [String] the current user's name.
  # @param context [String] more context about what led to the action.
  # @param status [String] the status to be applied to the row.
  # @param schema [String] the schema that the table belongs to. Defaults to: 'public'.
  def log_action(table_name, id, action, user_name: nil, context: nil, status: nil, schema: 'public')
    DB[Sequel[:audit][:logged_action_details]].insert(schema_name: schema,
                                                      table_name: table_name.to_s,
                                                      row_data_id: id,
                                                      action: action,
                                                      user_name: user_name,
                                                      context: context,
                                                      status: status)
  end
  # rubocop:enable Metrics/ParameterLists

  def self.inherited(klass)
    klass.extend(MethodBuilder)
  end

  private

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
end

module MethodBuilder
  # Define a +for_select_table_name+ method in a repo.
  # The method returns an array of values for use in e.g. a select dropdown.
  #
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
  #
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
  #
  # Call like this: +crud_calls_for+ :table_name.
  #
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
  # exclude: Array
  # - A list of symbols to exclude (:create, :update, :delete)
  def crud_calls_for(table_name, options = {})
    name    = options[:name] || table_name
    wrapper = options[:wrapper]
    skip    = options[:exclude] || []

    unless wrapper.nil?
      define_method(:"find_#{name}") do |id|
        find(table_name, wrapper, id)
      end
    end

    unless skip.include?(:create)
      define_method(:"create_#{name}") do |attrs|
        create(table_name, attrs)
      end
    end

    unless skip.include?(:update)
      define_method(:"update_#{name}") do |id, attrs|
        update(table_name, id, attrs)
      end
    end

    return if skip.include?(:delete)

    define_method(:"delete_#{name}") do |id|
      delete(table_name, id)
    end
  end
end
