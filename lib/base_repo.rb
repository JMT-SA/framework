# frozen_string_literal: true

class BaseRepo # rubocop:disable Metrics/ClassLength
  include Crossbeams::Responses

  # Wraps Sequel's transaction so that it is not exposed to calling code.
  #
  # @param block [Block] the work to take place within the transaction.
  # @return [void] whatever the block returns.
  def transaction(&block)
    DB.transaction(&block)
  end

  # Return all rows from a table as instances of the given wrapper.
  #
  # @param table_name [Symbol] the db table name.
  # @param wrapper [Class] the class of the object to return.
  # @param args [Hash] the optional where-clause conditions.
  # @return [Array] the table rows.
  def all(table_name, wrapper, args = nil)
    all_hash(table_name, args).map { |r| wrapper.new(r) }
  end

  # Return all rows from a table as Hashes.
  #
  # @param table_name [Symbol] the db table name.
  # @param args [Hash] the optional where-clause conditions.
  # @return [Array] the table rows.
  def all_hash(table_name, args = nil)
    args.nil? ? DB[table_name].all : DB[table_name].where(args).all
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

  # Find a row in a table with one or more associated sub-tables.
  # Returns nil if it is not found.
  # Returns a Hash if no wrapper is provided, else an instance of the wrapper class.
  #
  # Each Hash in the sub_tables array must include:
  # sub_table: Symbol - if no other options provided, assumes that the sub table has a column named "main_table_id" and all columns are returned.
  #
  # Optional keys:
  # columns: Array of Symbols - one for each desired column. If not present, all columns are returned
  # uses_join_table: Boolean - if true, will create a join table name using main_table and sub_table names sorted and joined with "_".
  # join_table: String - if present, use this as the join table.
  # active_only: Boolean (Only return active rows.)
  # inactive_only: Boolean (Only return inactive rows. The key in the main hash becomes :inactive_sub_table)
  #
  # examples:
  #     find_with_association(:security_groups, 123, sub_tables: [{ sub_table: :security_groups, uses_join_table: true }], SecurityGroupWithPermissions)
  #     find_with_association(:security_groups, 123, sub_tables: [{ sub_table: :security_groups, join_table: :security_groups_security_permissions }])
  #     find_with_association(:programs, 123, sub_tables: [{ sub_table: :program_functions },
  #                                                        { sub_table: :users, uses_join_table: true, active_only: true, columns: [:id, :user_name] }])
  #
  # @param table_name [Symbol] the db table name.
  # @param id [Integer] the id of the row.
  # @param sub_tables [Array] the rules for how to find associated rows.
  # @param wrapper [Class, nil] the class of the object to return.
  # @return [Object, nil, Hash] the row wrapped in a new wrapper object.
  def find_with_association(table_name, id, sub_tables: [], wrapper: nil)
    rec = find_hash(table_name, id)
    return nil if rec.nil?
    return rec if sub_tables.empty? && wrapper.nil?
    return wrapper.new(rec) if sub_tables.empty?

    sub_tables.each { |sub| rec = add_association(table_name, id, rec, sub) }

    return rec if wrapper.nil?
    wrapper.new(rec)
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

  # Helper to convert rows of records to a Hash that can be used for optgroups in a select.
  # Pass the records, and field names for the group, label and value elements.
  #
  # @param recs [Array] the records to process - an array of Hashes.
  # @param group_name [Symbol, String] the column with values to group by.
  # @param label [Symbol, String] the column to display as a label in a select.
  # @param value [Symbol, String] the column to act as the value in a select. Defaults to the same as the label.
  #
  # Example
  #    recs = [{type: 'A', sub: 'B', id: 1},
  #            {type: 'A', sub: 'C', id: 2},
  #            {type: 'B', sub: 'D', id: 4},
  #            {type: 'A', sub: 'E', id: 7}]
  #    optgroup_array(recs, :type, :sub, :id)
  #    # => { 'A' => [['B', 1], ['C', 2], ['E', 7]], 'B' => [['D', 4]] }
  def optgroup_array(recs, group_name, label, value = label)
    Hash[recs.map { |r| [r[group_name], r[label], r[value]] }.group_by(&:first).map { |k, v| [k, v.map { |i| [i[1], i[2]] }] }]
  end

  # Log the context of a transaction. Useful for joining to logged_actions table which has no context.
  #
  # @param user_name [String] the current user's name.
  # @param context [String] more context about what led to the action.
  # @param route_url [String] the application route that led to the transaction.
  def log_action(user_name: nil, context: nil, route_url: nil)
    DB[Sequel[:audit][:logged_action_details]].insert(user_name: user_name,
                                                      context: context,
                                                      route_url: route_url)
  end

  def self.inherited(klass)
    klass.extend(MethodBuilder)
  end

  private

  def unpack_sub_table_rule(main_table, sub)
    inflector = Dry::Inflector.new
    main_table_id = "#{inflector.singularize(main_table)}_id".to_sym
    sub_table_id = "#{inflector.singularize(sub.fetch(:sub_table))}_id".to_sym
    join_table = sub_table_join_table(main_table, sub[:sub_table], sub[:uses_join_table], sub[:join_table])
    cols = columns_from_sub_table(sub)
    [main_table_id, sub[:sub_table], sub_table_id, join_table, cols]
  end

  def columns_from_sub_table(sub)
    # If a list of columns is specified, return just those columns.
    # Otherwise default to all columns.
    sub[:columns] || Sequel.lit('*')
  end

  def sub_table_join_table(main_table, sub_table, uses_join_table, join_table)
    return nil unless join_table || uses_join_table
    return join_table unless uses_join_table
    [main_table, sub_table].sort.join('_').to_sym
  end

  def add_association(main_table, id, rec, sub)
    main_table_id, sub_table, sub_table_id, join_table, cols = unpack_sub_table_rule(main_table, sub)

    if sub[:active_only]
      add_active_sub_table_recs(rec, id, main_table_id, sub_table, sub_table_id, join_table, cols)
    elsif sub[:inactive_only]
      add_inactive_sub_table_recs(rec, id, main_table_id, sub_table, sub_table_id, join_table, cols)
    else
      add_sub_table_recs(rec, id, main_table_id, sub_table, sub_table_id, join_table, cols)
    end
  end

  def add_active_sub_table_recs(rec, id, main_table_id, sub_table, sub_table_id, join_table, cols) # rubocop:disable Metrics/ParameterLists
    rec[sub_table] = if join_table
                       DB[sub_table].where(id: DB[join_table].where(main_table_id => id).select(sub_table_id)).select(*cols).where(:active).all
                     else
                       DB[sub_table].where(main_table_id => id).select(*cols).where(:active).all
                     end
    rec
  end

  def add_inactive_sub_table_recs(rec, id, main_table_id, sub_table, sub_table_id, join_table, cols) # rubocop:disable Metrics/ParameterLists
    rec["inactive_#{sub_table}".to_sym] = if join_table
                                            DB[sub_table].where(id: DB[join_table].where(main_table_id => id).select(sub_table_id)).select(*cols).where(active: false).all
                                          else
                                            DB[sub_table].where(main_table_id => id).select(*cols).where(active: false).all
                                          end
    rec
  end

  def add_sub_table_recs(rec, id, main_table_id, sub_table, sub_table_id, join_table, cols) # rubocop:disable Metrics/ParameterLists
    rec[sub_table] = if join_table
                       DB[sub_table].where(id: DB[join_table].where(main_table_id => id).select(sub_table_id)).select(*cols).all
                     else
                       DB[sub_table].where(main_table_id => id).select(*cols).all
                     end
    rec
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
  def build_for_select(table_name, options = {}) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize
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
  def crud_calls_for(table_name, options = {}) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize
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
