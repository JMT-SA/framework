# frozen_string_literal: true

# Find an entity and associated entities.
class BaseRepoAssocationFinder # rubocop:disable Metrics/ClassLength
  def initialize(table_name, id, sub_tables: [], parent_tables: [], lookup_functions: [], wrapper: nil) # rubocop:disable Metrics/ParameterLists
    raise ArgumentError unless table_name.is_a?(Symbol)
    @main_table = table_name
    @id = id
    @sub_tables = sub_tables
    @parent_tables = parent_tables
    @lookup_functions = lookup_functions
    @wrapper = wrapper
    assert_lookup_functions_valid!
    assert_sub_tables_valid!
    assert_parent_tables_valid!
    @inflector = Dry::Inflector.new
  end

  # Get the entity for the given id.
  # Then use the provided rules to add sub-table or parent table attributes to the entity.
  # Return as a Hash - unless a wrapper object was provided.
  def call
    @rec = DB[@main_table].where(id: @id).first
    return nil if @rec.nil?

    apply_lookup_functions
    apply_sub_tables
    apply_parent_tables

    return @rec if @wrapper.nil?
    @wrapper.new(@rec)
  end

  private

  VALID_LKP_KEYS = %i[function args col_name].freeze
  VALID_SUB_KEYS = %i[sub_table columns join_table uses_join_table active_only inactive_only].freeze
  VALID_PARENT_KEYS = %i[parent_table columns flatten_columns].freeze

  def main_table_id
    @main_table_id ||= "#{@inflector.singularize(@main_table)}_id".to_sym
  end

  def apply_lookup_functions
    return if @lookup_functions.empty?
    @lookup_functions.each { |rule| apply_lkp_function_rule(rule) }
  end

  def apply_sub_tables
    return if @sub_tables.empty?
    @sub_tables.each { |rule| apply_sub_table_rule(rule) }
  end

  def apply_parent_tables
    return if @parent_tables.empty?
    @parent_tables.each do |rule|
      @parent_table = rule.fetch(:parent_table)
      apply_parent_table_rule(rule)
    end
  end

  def assert_sub_tables_valid!
    @sub_tables.each do |rule|
      sub_table = rule.fetch(:sub_table)
      raise ArgumentError, "Sub_table #{sub_table} must be a Symbol" unless sub_table.is_a?(Symbol)
      rule.keys.each { |k| raise ArgumentError, "Unknown sub-table key: #{k}" unless VALID_SUB_KEYS.include?(k) }
      rule.keys.each { |k| validate_sub_table_rule!(k, rule) }
    end
  end

  def assert_lookup_functions_valid!
    @lookup_functions.each do |rule|
      function = rule.fetch(:function)
      args = rule.fetch(:args)
      raise ArgumentError, "Args for function #{function} must be an Array" unless args.is_a?(Array)
      _ = rule.fetch(:col_name)
      rule.keys.each { |k| raise ArgumentError, "Unknown lookup-function key: #{k}" unless VALID_LKP_KEYS.include?(k) }
    end
  end

  def assert_parent_tables_valid!
    @parent_tables.each do |rule|
      parent_table = rule.fetch(:parent_table)
      raise ArgumentError, "parent_table #{parent_table} must be a Symbol" unless parent_table.is_a?(Symbol)
      rule.keys.each { |k| raise ArgumentError, "Unknown parent-table key: #{k}" unless VALID_PARENT_KEYS.include?(k) }
    end
  end

  def validate_sub_table_rule!(key, rule)
    case key
    when :columns
      validate_columns!(rule)
    when :join_table, :sub_table
      raise ArgumentError unless rule[key].is_a?(Symbol)
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
        @rec[key]
      when String
        "'#{key}'"
      else
        key
      end
    end
    col_name = rule[:col_name]
    @rec[col_name] = DB["SELECT #{function}(#{args.join(',')})"].get
  end

  def apply_parent_table_rule(rule)
    cols = rule[:columns] || Sequel.lit('*')
    entity = DB[@parent_table].where(id: @rec[parent_table_id]).select(*cols).first
    add_flattened_columns(rule, entity)
    @rec[@inflector.singularize(@parent_table).to_sym] = entity unless entity.empty?
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
    sub[:columns] || Sequel.lit('*')
  end

  def sub_table_join_table(uses_join_table, join_table)
    return nil unless join_table || uses_join_table
    return join_table unless uses_join_table
    [@main_table, @sub_table].sort.join('_').to_sym
  end

  def add_active_sub_table_recs(cols)
    @rec[@sub_table] = if @join_table
                         active_inactive_join_call(cols, true)
                       else
                         active_inactive_belongs_call(cols, true)
                       end
  end

  def add_inactive_sub_table_recs(cols)
    @rec[inactive_key] = if @join_table
                           active_inactive_join_call(cols, false)
                         else
                           active_inactive_belongs_call(cols, false)
                         end
  end

  def active_inactive_belongs_call(cols, active)
    ds = DB[@sub_table].where(main_table_id => @id).select(*cols)
    active ? ds.where(:active).all : ds.where(active: false).all
  end

  def active_inactive_join_call(cols, active)
    ds = DB[@sub_table].where(id: DB[@join_table].where(main_table_id => @id).select(@sub_table_id)).select(*cols)
    active ? ds.where(:active).all : ds.where(active: false).all
  end

  def inactive_key
    "inactive_#{@sub_table}".to_sym
  end

  def add_sub_table_recs(cols)
    @rec[@sub_table] = if @join_table
                         DB[@sub_table].where(id: DB[@join_table].where(main_table_id => @id).select(@sub_table_id)).select(*cols).all
                       else
                         DB[@sub_table].where(main_table_id => @id).select(*cols).all
                       end
  end
end
