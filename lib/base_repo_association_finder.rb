# frozen_string_literal: true

# Find an entity and associated entities.
class BaseRepoAssocationFinder # rubocop:disable Metrics/ClassLength
  def initialize(table_name, id, sub_tables: [], parent_tables: [], lookup_functions: [], wrapper: nil) # rubocop:disable Metrics/ParameterLists
    raise ArgumentError unless table_name.is_a?(Symbol)

    @main_table = table_name
    @id = id.to_s.blank? ? nil : id
    @sub_tables = sub_tables
    @parent_tables = parent_tables
    @lookup_functions = lookup_functions
    @wrapper = wrapper
    assert_lookup_functions_valid!
    assert_sub_tables_valid!
    assert_parent_tables_valid!
    @inflector = Dry::Inflector.new
  end

  # Get the entity for the given id (include function lookups if any are provided).
  # Then use the provided rules to add sub-table or parent table attributes to the entity.
  # Return as a Hash - unless a wrapper object was provided.
  def call
    @dataset = DB[@main_table]
    apply_lookup_functions
    @rec = @dataset.where(id: @id).first
    return nil if @rec.nil?

    apply_sub_tables
    apply_parent_tables

    return @rec if @wrapper.nil?

    @wrapper.new(@rec)
  end

  private

  VALID_LKP_KEYS = %i[function args col_name].freeze
  VALID_SUB_KEYS = %i[sub_table columns join_table uses_join_table active_only inactive_only id_keys_column one_to_one].freeze
  VALID_PARENT_KEYS = %i[parent_table columns flatten_columns foreign_key].freeze

  def main_table_id
    @main_table_id ||= "#{@inflector.singularize(@main_table)}_id".to_sym
  end

  def apply_lookup_functions
    return if @lookup_functions.empty?

    @function_selects = []
    @lookup_functions.each { |rule| apply_lkp_function_rule(rule) }
    @dataset = @dataset.select(Sequel.lit('*'), *@function_selects)
  end

  def apply_sub_tables
    return if @sub_tables.empty?

    @sub_tables.each { |rule| apply_sub_table_rule(rule) }
  end

  def apply_parent_tables
    return if @parent_tables.empty?

    @parent_tables.each do |rule|
      @parent_table = rule.fetch(:parent_table)
      @foreign_key = rule[:foreign_key]
      apply_parent_table_rule(rule)
    end
  end

  def assert_sub_tables_valid!
    @sub_tables.each do |rule|
      sub_table = rule.fetch(:sub_table)
      raise ArgumentError, "Sub_table #{sub_table} must be a Symbol" unless sub_table.is_a?(Symbol)
      raise ArgumentError, "Sub_table #{sub_table} cannot be joined via a join table AND an id keys array" if rule.key?(:id_keys_column) && (rule.key?(:join_table) || rule.key?(:uses_join_table))

      rule.each_key { |k| raise ArgumentError, "Unknown sub-table key: #{k}" unless VALID_SUB_KEYS.include?(k) }
      rule.each_key { |k| validate_sub_table_rule!(k, rule) }
    end
  end

  def assert_lookup_functions_valid!
    @lookup_functions.each do |rule|
      function = rule.fetch(:function)
      args = rule.fetch(:args)
      raise ArgumentError, "Args for function #{function} must be an Array" unless args.is_a?(Array)

      _ = rule.fetch(:col_name)
      rule.each_key { |k| raise ArgumentError, "Unknown lookup-function key: #{k}" unless VALID_LKP_KEYS.include?(k) }
    end
  end

  def assert_parent_tables_valid!
    @parent_tables.each do |rule|
      parent_table = rule.fetch(:parent_table)
      raise ArgumentError, "parent_table #{parent_table} must be a Symbol" unless parent_table.is_a?(Symbol)

      rule.each_key { |k| raise ArgumentError, "Unknown parent-table key: #{k}" unless VALID_PARENT_KEYS.include?(k) }
      raise ArgumentError, 'Parent tables columns rule must be an Array' if rule[:columns] && !rule[:columns].is_a?(Array)
    end
  end

  def validate_sub_table_rule!(key, rule) # rubocop:disable Metrics/CyclomaticComplexity
    case key
    when :columns
      validate_columns!(rule)
    when :join_table, :sub_table, :id_keys_column
      raise ArgumentError unless rule[key].is_a?(Symbol)
    when :one_to_one
      raise ArgumentError unless rule[key].is_a?(Hash)
    else
      raise ArgumentError unless rule[key] == true || rule[key] == false
    end
  end

  def validate_columns!(rule)
    raise ArgumentError unless rule[:columns].is_a?(Array)
    raise ArgumentError if rule[:columns].any? { |c| !c.is_a?(Symbol) }
  end

  def apply_lkp_function_rule(rule)
    function = rule[:function]
    args = rule[:args].map do |key|
      case key
      when Symbol
        key
      when String
        "'#{key}'"
      else
        key
      end
    end
    col_name = rule[:col_name]
    @function_selects << Sequel.lit("#{function}(#{args.join(',')}) AS #{col_name}")
  end

  def apply_parent_table_rule(rule)
    cols = rule[:columns] || Sequel.lit('*')
    entity = DB[@parent_table].where(id: @rec[@foreign_key || parent_table_id]).select(*cols).first
    if entity.nil?
      blank_parent_entity(cols, rule)
    else
      add_flattened_columns(rule, entity)
      @rec[parent_table_key] = entity unless entity.empty?
    end
  end

  def blank_parent_entity(cols, rule)
    cols = DB[@parent_table].columns if cols == Sequel.lit('*')
    (rule[:flatten_columns] || []).each do |col, new_name|
      cols.delete(col)
      @rec[new_name] = nil
    end
    nc = {}
    nc = cols.map { |c| [c, nil] }.to_h unless cols.empty?
    @rec[parent_table_key] = nc unless cols.empty?
  end

  def parent_table_key
    if @foreign_key
      @foreign_key.to_s.sub(/_id$/, '').to_sym
    else
      @inflector.singularize(@parent_table).to_sym
    end
  end

  def parent_table_id
    "#{@inflector.singularize(@parent_table)}_id".to_sym
  end

  def add_flattened_columns(rule, entity)
    (rule[:flatten_columns] || []).each do |col, new_name|
      @rec[new_name] = entity.delete(col)
    end
  end

  def apply_sub_table_rule(sub)
    cols = unpack_sub_table_rule(sub)
    if sub[:active_only]
      add_active_sub_table_recs(cols)
    elsif sub[:inactive_only]
      add_inactive_sub_table_recs(cols)
    else
      add_sub_table_recs(cols)
    end
  end

  def unpack_sub_table_rule(sub)
    @sub_table = sub.fetch(:sub_table)
    @sub_table_id = "#{@inflector.singularize(@sub_table)}_id".to_sym
    @join_table = sub_table_join_table(sub[:uses_join_table], sub[:join_table])
    @id_keys_column = sub[:id_keys_column]
    @one_to_one = sub[:one_to_one]
    sub[:columns] || Sequel.lit('*')
  end

  def sub_table_join_table(uses_join_table, join_table)
    return nil unless join_table || uses_join_table
    return join_table unless uses_join_table

    [@main_table, @sub_table].sort.join('_').to_sym
  end

  def add_active_sub_table_recs(cols)
    sub_recs = if @join_table
                 active_inactive_join_call(cols, true)
               elsif @id_keys_column
                 active_inactive_array_call(cols, true)
               else
                 active_inactive_belongs_call(cols, true)
               end
    if @one_to_one
      flatten_sub_recs(sub_recs)
    else
      @rec[@sub_table] = sub_recs
    end
  end

  def add_inactive_sub_table_recs(cols)
    sub_recs = if @join_table
                 active_inactive_join_call(cols, false)
               elsif @id_keys_column
                 active_inactive_array_call(cols, true)
               else
                 active_inactive_belongs_call(cols, false)
               end
    if @one_to_one
      flatten_sub_recs(sub_recs)
    else
      @rec[inactive_key] = sub_recs
    end
  end

  def active_inactive_belongs_call(cols, active, all: false)
    ds = DB[@sub_table].where(main_table_id => @id).select(*cols)
    return ds.all if all

    active ? ds.where(:active).all : ds.where(active: false).all
  end

  def active_inactive_join_call(cols, active, all: false)
    ds = DB[@sub_table].where(id: DB[@join_table].where(main_table_id => @id).select(@sub_table_id)).select(*cols)
    return ds.all if all

    active ? ds.where(:active).all : ds.where(active: false).all
  end

  def active_inactive_array_call(cols, active, all: false)
    arr = sub_table_array_ids
    ds = DB[@sub_table].where(id: arr).select(*cols)
    return ds.all if all

    active ? ds.where(:active).all : ds.where(active: false).all
  end

  def inactive_key
    "inactive_#{@sub_table}".to_sym
  end

  def sub_table_array_ids
    DB[@main_table].where(id: @id).get(@id_keys_column).to_a
  end

  def add_sub_table_recs(cols)
    sub_recs = if @join_table
                 active_inactive_join_call(cols, true, all: true)
               elsif @id_keys_column
                 active_inactive_array_call(cols, true, all: true)
               else
                 active_inactive_belongs_call(cols, true, all: true)
               end
    if @one_to_one
      flatten_sub_recs(sub_recs)
    else
      @rec[@sub_table] = sub_recs
    end
  end

  def flatten_sub_recs(sub_recs)
    raise Crossbeams::InfoError, "Sub_table #{@sub_table} cannot return more than one row for one-to-one" if sub_recs.length > 1

    entity = sub_recs.length == 1 ? sub_recs.first : {}
    (@one_to_one || []).each do |col, new_name|
      @rec[new_name] = entity.delete(col)
    end
  end
end
