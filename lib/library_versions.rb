# frozen_string_literal: true

class LibraryVersions
  attr_reader :requested_libs

  LIB_STRATEGIES = {
    layout: [:gemver, 'Crossbeams::Layout'],
    dataminer: [:gemver, 'Crossbeams::Dataminer'],
    label_designer: [:gemver, 'Crossbeams::LabelDesigner'],
    rackmid: [:gemver, 'Crossbeams::RackMiddleware'],
    datagrid: [:gemver, 'Roda::DataGrid'],
    ag_grid: %i[jsver ag_grid],
    selectr: %i[jsver selectr]
  }.freeze

  def initialize(*requested_libs)
    @requested_libs = requested_libs
  end

  def to_html
    version_strings = requested_libs.map { |r| resolve(r) }
    s = String.new('<h2>Gem and js library Versions</h2><ul><li>')
    s << version_strings.join('</li><li>')
    s << '</li></ul>'
    <<~HTML
      <h2>Gem and js library Versions</h2>
      <ul><li>
        #{version_strings.join('</li><li>')}
      </li></ul>
    HTML
  end

  def resolve(r)
    send(*LIB_STRATEGIES[r])
  end

  def gemver(klass)
    "#{klass}: #{Object.const_get(klass).const_get('VERSION')}"
  end

  def jsver(key)
    case key
    when :ag_grid
      ag_grid_version
    when :selectr
      selectr_version
    else
      "Unknown directive: #{key}"
    end
  end

  def ag_grid_version
    "AG-Grid: #{File.readlines('public/js/ag-grid-enterprise.min.js').first.chomp.split(' v').last}"
  end

  def selectr_version
    "Selectr: #{File.readlines('public/js/selectr.min.js')[1].chomp.split(' ').last}"
  end
end
