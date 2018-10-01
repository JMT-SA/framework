# frozen_string_literal: true

class BaseRepoAssocationFinder
  def initialize(table_name, id, sub_tables: [], wrapper: nil)
    raise ArgumentError unless table_name.is_a?(Symbol)
    @main_table = table_name
    @id = id
    @sub_tables = sub_tables
    @wrapper = wrapper
    assert_sub_tables_valid!
    @inflector = Dry::Inflector.new
  end

  def call
    @rec = DB[@main_table].where(id: @id).first
    return nil if @rec.nil?

    apply_sub_tables

    return @rec if @wrapper.nil?
    @wrapper.new(@rec)
  end

  private

  VALID_KEYS = %i[sub_table columns join_table uses_join_table active_only inactive_only].freeze

  def assert_sub_tables_valid!
    @sub_tables.each do |rule|
      sub_table = rule.fetch(:sub_table)
      raise ArgumentError, "Sub_table #{sub_table} must be a Symbol" unless sub_table.is_a?(Symbol)
      rule.keys.each { |k| raise ArgumentError, "Unknown sub-table key: #{k}" unless VALID_KEYS.include?(k) }
      rule.keys.each { |k| validate_rule!(k, rule) }
    end
  end

  def validate_rule!(key, rule)
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

  def apply_sub_tables
    return if @sub_tables.empty?
    @sub_tables.each { |sub| apply_sub_table_rule(sub) }
  end

  def main_table_id
    @main_table_id ||= "#{@inflector.singularize(@main_table)}_id".to_sym
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
                         DB[@sub_table].where(id: DB[@join_table].where(main_table_id => @id).select(@sub_table_id)).select(*cols).where(:active).all
                       else
                         DB[@sub_table].where(main_table_id => @id).select(*cols).where(:active).all
                       end
    @rec
  end

  def add_inactive_sub_table_recs(cols)
    @rec["inactive_#{@sub_table}".to_sym] = if @join_table
                                              DB[@sub_table].where(id: DB[@join_table].where(main_table_id => @id).select(@sub_table_id)).select(*cols).where(active: false).all
                                            else
                                              DB[@sub_table].where(main_table_id => @id).select(*cols).where(active: false).all
                                            end
    @rec
  end

  def add_sub_table_recs(cols)
    @rec[@sub_table] = if @join_table
                         DB[@sub_table].where(id: DB[@join_table].where(main_table_id => @id).select(@sub_table_id)).select(*cols).all
                       else
                         DB[@sub_table].where(main_table_id => @id).select(*cols).all
                       end
    @rec
  end
end

