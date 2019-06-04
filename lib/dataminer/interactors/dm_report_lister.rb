class DmReportLister
  def initialize(path)
    @path = Pathname.new(path)
    return if File.exist?(File.join(path, '.dm_report_list.yml'))

    make_list
    persist_list
  end

  def get_report_by_id(id)
    config_file       = File.join(path, '.dm_report_list.yml')
    report_dictionary = YAML.load_file(config_file)
    this_report       = report_dictionary[id]
    persistor         = Crossbeams::Dataminer::YamlPersistor.new(this_report[:file])
    Crossbeams::Dataminer::Report.load(persistor)
  end

  def get_file_name_by_id(id)
    config_file       = File.join(path, '.dm_report_list.yml')
    report_dictionary = YAML.load_file(config_file)
    this_report       = report_dictionary[id]
    this_report[:file]
  end

  def get_report_list(options = { from_cache: false, persist: false })
    make_list(options[:from_cache])
    persist_list if options[:persist]
    report_lookup.map { |id, lkp| { id: id, file: lkp[:file], caption: lkp[:caption], crosstab: lkp[:crosstab] } }
  end

  def get_crosstab_hash_by_id(id)
    config_file       = File.join(path, '.dm_report_list.yml')
    report_dictionary = YAML.load_file(config_file)
    this_report       = report_dictionary[id]
    yml               = YAML.load_file(this_report[:file])
    yml[:crosstab]
  end

  private

  attr_reader :path, :report_lookup

  def make_list(from_cache = false) # rubocop:disable Metrics/AbcSize
    @report_lookup = {}
    if from_cache
      @report_lookup = YAML.load_file(File.join(path, '.dm_report_list.yml'))
    else
      ymlfiles = File.join(path, '**', '*.yml')
      yml_list = Dir.glob(ymlfiles)

      yml_list.each do |yml_file|
        index = File.basename(yml_file).sub(File.extname(yml_file), '')
        yp    = Crossbeams::Dataminer::YamlPersistor.new(yml_file)
        @report_lookup[index] = { file: yml_file, caption: Crossbeams::Dataminer::Report.load(yp).caption, crosstab: !yp.to_hash[:crosstab].nil? }
      end
    end
  end

  def persist_list
    File.open(File.join(path, '.dm_report_list.yml'), 'w') { |f| YAML.dump(report_lookup, f) }
  end
end
