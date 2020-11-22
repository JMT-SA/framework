# frozen_string_literal: true

module UiRules
  class HideGridColumnsRule < Base
    def generate_rules
      make_form_object

      if @mode == :list
        get_report_data(:lists, @options[:file])
      elsif @mode == :search
        get_report_data(:searches, @options[:file])
      else
        common_values_for_fields common_fields
      end

      form_name 'report'
    end

    def common_fields
      {
        lists: { renderer: :select, options: make_lists, prompt: true },
        searches: { renderer: :select, options: make_searches, prompt: true }
      }
    end

    def make_form_object
      @form_object = OpenStruct.new(lists: nil, searches: nil)
    end

    def make_lists
      dir = File.expand_path('../lists', ENV['GRID_QUERIES_LOCATION'])
      Dir.glob(File.join(dir, '*.yml')).map { |f| f.delete_prefix("#{dir}/") }.sort
    end

    def make_searches
      dir = File.expand_path('../searches', ENV['GRID_QUERIES_LOCATION'])
      Dir.glob(File.join(dir, '*.yml')).map { |f| f.delete_prefix("#{dir}/") }.sort
    end

    def get_report_data(type, file)
      dir = File.expand_path("../#{type}", ENV['GRID_QUERIES_LOCATION'])
      fn = File.join(dir, file)
      hash = YAML.load_file(fn)

      query_file = hash[:dataminer_definition]
      fn = File.join(ENV['GRID_QUERIES_LOCATION'], "#{query_file}.yml")
      hash = YAML.load_file(fn)
      rules[:type] = type == :lists ? 'LIST' : 'SEARCH'
      rules[:caption] = hash[:caption]
    end
  end
end
