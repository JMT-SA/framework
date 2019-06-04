class DmConverter
  def initialize(path)
    @path = path
  end

  def convert_hash(hash, name) # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
    # ...main_table_name, default_index_name...
    grid_configs = hash['grid_configs'] || {}
    hidden = grid_configs['hidden'] || {}
    groupable_fields = grid_configs['groupable_fields'] || []
    sum_fields = grid_configs['group_fields_to_sum'] || []
    avg_fields = grid_configs['group_fields_to_avg'] || []
    min_fields = grid_configs['group_fields_to_min'] || []
    max_fields = grid_configs['group_fields_to_max'] || []
    grouped_fields = grid_configs['group_fields'] || []
    grouped_fields = [] unless grid_configs['grouped']
    fields = hash['fields'] || {}

    rpt = Crossbeams::Dataminer::Report.new(grid_configs['caption'] || 'Unknown report')
    rpt.sql = hash['query']
    rpt.ordered_columns.each do |column|
      rpt.column(column.name).width = grid_configs['column_widths'][column.name] if grid_configs.dig('column_widths', column.name)
      rpt.column(column.name).data_type = grid_configs['data_types'][column.name].to_sym if grid_configs.dig('data_types', column.name)
      rpt.column(column.name).caption = grid_configs['column_captions'][column.name] if grid_configs.dig('column_captions', column.name)
      rpt.column(column.name).groupable = true if groupable_fields.include?(column.name)
      rpt.column(column.name).group_sum = true if sum_fields.include?(column.name)
      rpt.column(column.name).group_avg = true if avg_fields.include?(column.name)
      rpt.column(column.name).group_min = true if min_fields.include?(column.name)
      rpt.column(column.name).group_max = true if max_fields.include?(column.name)
      rpt.column(column.name).hide = true if hidden.include?(column.name)
      rpt.column(column.name).format = grid_configs['formats'][column.name].to_sym if grid_configs.dig('formats', column.name)
      rpt.column(column.name).group_by_seq = grouped_fields.index(column.name)
    end

    fields.each_value do |field_def|
      list_def = field_def['list']
      control_type = case field_def['field_type']
                     when 'lookup'
                       :list
                     when 'daterange'
                       :daterange
                     else
                       :text
                     end
      caption = field_def['caption']

      data_type = :string # ...check column for other type????
      param_name = field_def['field_name']
      rpt.ordered_columns.each do |column|
        data_type = column.data_type if column.namespaced_name == param_name
      end
      rpt.add_parameter_definition(Crossbeams::Dataminer::QueryParameterDefinition.new(param_name,
                                                                                       caption: caption,
                                                                                       data_type: data_type,
                                                                                       control_type: control_type,
                                                                                       ui_priority: 1,
                                                                                       default_value: nil,
                                                                                       list_def: list_def))
    end
    yp = Crossbeams::Dataminer::YamlPersistor.new(File.join(path, name))
    rpt.save(yp)
    rpt
  end

  private

  attr_reader :path
end
