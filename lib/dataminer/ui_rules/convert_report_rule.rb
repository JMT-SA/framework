# frozen_string_literal: true

module UiRules
  class ConvertReportRule < Base
    def generate_rules
      make_form_object

      common_values_for_fields common_fields

      form_name 'report'
    end

    def common_fields
      {
        database: { renderer: :select, options: DM_CONNECTIONS.databases(without_grids: true, without_system: true) },
        filename: { renderer: :hidden },
        temp_path: { renderer: :hidden },
        yml: { renderer: :hidden },
        sql: { renderer: :textarea, rows: 20 }
      }
    end

    def make_form_object
      yml  = @options[:tempfile].read # Store tmpfile so it's available for save? ... currently hiding yml in the form...
      hash = YAML.load(yml) # rubocop:disable Security/YAMLLoad
      @form_object = OpenStruct.new(database: nil, filename: @options[:filename], yml: yml, temp_path: @options[:tempfile].path, sql: clean_where(hash['query']))
    end

    def clean_where(sql)
      rems = sql.scan(/\{(.+?)\}/).flatten.map { |s| "#{s}={#{s}}" }
      rems.each { |r| sql.gsub!(/and\s+#{r}/i, '') }
      rems.each { |r| sql.gsub!(r, '') }
      sql.sub!(/where\s*\(\s+\)/i, '')
      sql
    end
  end
end
