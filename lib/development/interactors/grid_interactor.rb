# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

module DevelopmentApp
  class GridInteractor < BaseInteractor
    def list_grids
      row_defs = []
      dm_path  = Pathname.new('grid_definitions/dataminer_queries')
      ymlfiles = File.join(list_path, '**', '*.yml')
      yml_list = Dir.glob(ymlfiles).sort

      yml_list.each do |yml_file|
        row_defs << list_row_def(yml_file, dm_path)
      end

      {
        columnDefs: list_col_defs,
        rowDefs: row_defs
      }
    end

    def list_definition(file)
      load_list_file(file)
    end

    def grid_page_controls(file)
      row_defs = page_control_row_defs(file)
      {
        columnDefs: page_control_col_defs(file),
        rowDefs: row_defs
      }
    end

    def grid_multiselects(file)
      row_defs = multiselect_row_defs(file)
      {
        columnDefs: multiselect_col_defs,
        rowDefs: row_defs
      }
    end

    def grid_conditions(file)
      row_defs = condition_row_defs(file)
      {
        columnDefs: condition_col_defs,
        rowDefs: row_defs
      }
    end

    def grid_actions(file)
      row_defs = action_row_defs(file)
      {
        columnDefs: action_col_defs,
        rowDefs: row_defs
      }
    end

    def page_control(file, index)
      page_controls = load_list_file(file)[:page_controls]
      page_controls[index].merge(list_file: file, index: index)
    end

    def update_page_control(params)
      file = params[:list_file]
      index = params[:index].to_i
      list = load_list_file(file)
      page_control = list[:page_controls][index]
      page_control[:text] = params[:text]
      list[:page_controls][index] = page_control
      save_list_file(file, list)
      success_response("Updated #{params[:text]}",
                       page_control)
    end

    private

    def file_path(file)
      File.join(list_path, "#{file}.yml")
    end

    def list_path
      Pathname.new('grid_definitions/lists')
    end

    def load_list_file(file)
      YAML.load(File.read(file_path(file)))                               # rubocop: disable Security/YAMLLoad
    end

    def save_list_file(file, list)
      File.open(file_path(file), 'w') { |f| f << list.to_yaml }
    end

    def page_control_col_defs(file)
      action_cols = [{ text: 'edit', icon: 'edit', url: "/development/grids/grid_page_controls/#{file}/$col0$", col0: 'id', popup: true, title: 'Edit page control' }]

      [{ headerName: '', pinned: 'left',
         width: 60,
         suppressMenu: true,   suppressSorting: true,   suppressMovable: true,
         suppressFilter: true, enableRowGroup: false,   enablePivot: false,
         enableValue: false,   suppressCsvExport: true, suppressColumnsToolPanel: true,
         suppressFiltersToolPanel: true,
         valueGetter: action_cols.to_json.to_s,
         colId: 'action_links',
         cellRenderer: 'crossbeamsGridFormatters.menuActionsRenderer' },
       { headerName: 'Text', field: 'text', width: 300 },
       { headerName: 'Control Type', field: 'control_type' },
       { headerName: 'Style', field: 'style' },
       { headerName: 'Behaviour', field: 'behaviour' },
       { headerName: 'URL', field: 'url', width: 500 },
       { headerName: 'Index', field: 'id', hide: true }]
    end

    def page_control_row_defs(file)
      rows = []
      (load_list_file(file)[:page_controls] || []).each_with_index do |page_control, index|
        control = OpenStruct.new(page_control)
        rows << {
          text: control.text,
          control_type: control.control_type,
          style: control.style,
          behaviour: control.behaviour,
          url: control.url,
          id: index
        }
      end
      rows
    end

    def multiselect_col_defs
      action_cols = [{ text: 'edit', icon: 'edit', url: '/development/grids/lists/edit/$col0$', col0: 'file' }]

      [{ headerName: '', pinned: 'left',
         width: 60,
         suppressMenu: true,   suppressSorting: true,   suppressMovable: true,
         suppressFilter: true, enableRowGroup: false,   enablePivot: false,
         enableValue: false,   suppressCsvExport: true, suppressColumnsToolPanel: true,
         suppressFiltersToolPanel: true,
         valueGetter: action_cols.to_json.to_s,
         colId: 'action_links',
         cellRenderer: 'crossbeamsGridFormatters.menuActionsRenderer' },
       { headerName: 'Key', field: 'key' },
       { headerName: 'URL', field: 'url', width: 500 },
       { headerName: 'Preselect', field: 'preselect', width: 500 },
       { headerName: 'Section Caption', field: 'section_caption', width: 500 },
       {
         headerName: 'Can clear?',
         field: 'can_be_cleared',
         cellRenderer: 'crossbeamsGridFormatters.booleanFormatter',
         cellClass: 'grid-boolean-column',
         width: 100
       },
       { headerName: 'Save method', field: 'multiselect_save_method' }]
    end

    def multiselect_row_defs(file)
      rows = []
      (load_list_file(file)[:multiselect] || []).each do |key, value|
        control = OpenStruct.new(value)
        rows << {
          key: key,
          url: control.url,
          preselect: control.preselect,
          section_caption: control.section_caption,
          can_be_cleared: control.can_be_cleared,
          multiselect_save_method: control.multiselect_save_method
        }
      end
      rows
    end

    def condition_col_defs
      action_cols = [{ text: 'edit', icon: 'edit', url: '/development/grids/lists/edit/$col0$', col0: 'file' }]

      [{ headerName: '', pinned: 'left',
         width: 60,
         suppressMenu: true,   suppressSorting: true,   suppressMovable: true,
         suppressFilter: true, enableRowGroup: false,   enablePivot: false,
         enableValue: false,   suppressCsvExport: true, suppressColumnsToolPanel: true,
         suppressFiltersToolPanel: true,
         valueGetter: action_cols.to_json.to_s,
         colId: 'action_links',
         cellRenderer: 'crossbeamsGridFormatters.menuActionsRenderer' },
       { headerName: 'Key', field: 'key' },
       { headerName: 'Column', field: 'col', width: 300 },
       { headerName: 'Operator', field: 'op' },
       { headerName: 'Value definition', field: 'val', width: 500 }]
    end

    def condition_row_defs(file)
      rows = []
      (load_list_file(file)[:conditions] || []).each do |key, value|
        value.each do |condition|
          control = OpenStruct.new(condition)
          rows << {
            key: key,
            col: control.col,
            op: control.op,
            val: control.val
          }
        end
      end
      rows
    end

    def action_col_defs
      action_cols = [{ text: 'edit', icon: 'edit', url: '/development/grids/lists/edit/$col0$', col0: 'file' }]

      [{ headerName: '', pinned: 'left',
         width: 60,
         suppressMenu: true,   suppressSorting: true,   suppressMovable: true,
         suppressFilter: true, enableRowGroup: false,   enablePivot: false,
         enableValue: false,   suppressCsvExport: true, suppressColumnsToolPanel: true,
         suppressFiltersToolPanel: true,
         valueGetter: action_cols.to_json.to_s,
         colId: 'action_links',
         cellRenderer: 'crossbeamsGridFormatters.menuActionsRenderer' },
       {
         headerName: 'Separator?',
         field: 'is_separator',
         cellRenderer: 'crossbeamsGridFormatters.booleanFormatter',
         cellClass: 'grid-boolean-column',
         width: 100
       },
       { headerName: 'Text', field: 'text', width: 300 },
       { headerName: 'Icon', field: 'icon' },
       { headerName: 'Title', field: 'title' },
       { headerName: 'Title Field', field: 'title_field' },
       {
         headerName: 'Popup',
         field: 'popup',
         cellRenderer: 'crossbeamsGridFormatters.booleanFormatter',
         cellClass: 'grid-boolean-column',
         width: 100
       },
       {
         headerName: 'Is Delete',
         field: 'is_delete',
         cellRenderer: 'crossbeamsGridFormatters.booleanFormatter',
         cellClass: 'grid-boolean-column',
         width: 100
       },
       { headerName: 'Auth program', field: 'auth_program' },
       { headerName: 'Auth permission', field: 'auth_permission' },
       { headerName: 'Hide if present', field: 'hide_if_present' },
       { headerName: 'Hide if null', field: 'hide_if_null' },
       { headerName: 'Hide if true', field: 'hide_if_true' },
       { headerName: 'Hide if false', field: 'hide_if_false' },
       { headerName: 'URL', field: 'url', width: 500 }]
    end

    def action_row_defs(file)
      rows = []
      (load_list_file(file)[:actions] || []).each do |action|
        if action[:separator]
          rows << { is_separator: true }
        else
          control = OpenStruct.new(action)
          rows << {
            text: control.text,
            icon: control.icon,
            title: control.title,
            title_field: control.title_field,
            popup: control.popup,
            is_delete: control.is_delete,
            auth_program: (control.auth || {})[:program],
            auth_permission: (control.auth || {})[:permission],
            hide_if_present: control.hide_if_present,
            hide_if_null: control.hide_if_null,
            hide_if_true: control.hide_if_true,
            hide_if_false: control.hide_if_false,
            url: control.url
          }
        end
      end
      rows
    end

    def list_col_defs
      action_cols = [{ text: 'edit', icon: 'edit', url: '/development/grids/lists/edit/$col0$', col0: 'file' }]

      [{ headerName: '', pinned: 'left',
         width: 60,
         suppressMenu: true,   suppressSorting: true,   suppressMovable: true,
         suppressFilter: true, enableRowGroup: false,   enablePivot: false,
         enableValue: false,   suppressCsvExport: true, suppressColumnsToolPanel: true,
         suppressFiltersToolPanel: true,
         valueGetter: action_cols.to_json.to_s,
         colId: 'action_links',
         cellRenderer: 'crossbeamsGridFormatters.menuActionsRenderer' },
       { headerName: 'List file name', field: 'file', width: 300 },
       { headerName: 'DM Query file', field: 'dm_file', width: 300 },
       { headerName: 'Report caption', field: 'caption', width: 300 }]
    end

    def list_row_def(yml_file, dm_path)
      index = File.basename(yml_file).sub(File.extname(yml_file), '')
      list_hash = YAML.load(File.read(yml_file))                               # rubocop: disable Security/YAMLLoad
      dm_file = File.join(dm_path, "#{list_hash[:dataminer_definition]}.yml")
      if File.exist?(dm_file)
        yp = Crossbeams::Dataminer::YamlPersistor.new(dm_file)
        caption = Crossbeams::Dataminer::Report.load(yp).caption
      else
        caption = 'THERE IS NO MATCHING DM FILE!'
      end
      { file: index, dm_file: list_hash[:dataminer_definition], caption: caption }
    end
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize
