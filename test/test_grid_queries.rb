# frozen_string_literal: true

require File.join(File.expand_path('./../', __FILE__), 'test_helper')

class TestGridQueries < MiniTestWithHooks
  def test_valid_ddl
    @current = 'No file loaded yet'
    queries = Dir.glob('grid_definitions/dataminer_queries/*.yml')
    queries.each do |file|
      @current = file

      persistor = Crossbeams::Dataminer::YamlPersistor.new(file)
      rpt = Crossbeams::Dataminer::Report.load(persistor)
      res = DB[rpt.runnable_sql].first
      if res.nil?
        assert_nil res
      else
        assert_instance_of Hash, res, "Grid #{file} did not return a hash"
      end
    end
  rescue StandardError
    puts "Failure for grid query definition: #{@current}"
    raise
  end
end
