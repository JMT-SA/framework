class GenerateNewScaffold < BaseService
  include UtilityFunctions
  attr_accessor :opts

  # >>> check yml popup on delete requirements
  # TODO: dry-validation: type to pre-strip strings...
  def initialize(params)
    @opts             = OpenStruct.new(params)
    @opts.new_applet  = @opts.applet == 'other'
    @opts.applet      = params[:other] if @opts.applet == 'other'
    @opts.program   ||= 'progname'
    @opts.singlename  = simple_single(@opts.table)
    @opts.klassname   = camelize(@opts.singlename)
    @opts.query_name  = params[:query_name]  || @opts.table
    @opts.list_name   = params[:list_name]   || @opts.table
    @opts.search_name = params[:search_name] || @opts.table
    @opts.label_field = params[:label_field]
    @opts.table_meta  = TableMeta.new(@opts.table)
    @opts.label_field = @opts.table_meta.likely_label_field if @opts.label_field.empty?
  end

  def call
    sources = { opts: opts, paths: {} }
    sources[:paths][:dm_query] = "grid_definitions/dataminer_queries/#{opts.table}.yml"
    sources[:paths][:list] = "grid_definitions/lists/#{opts.table}.yml"
    sources[:paths][:search] = "grid_definitions/searches/#{opts.table}.yml"
    sources[:paths][:repo] = "lib/#{opts.applet}/repositories/#{opts.singlename}_repo.rb"
    sources[:paths][:entity] = "lib/#{opts.applet}/entities/#{opts.singlename}.rb"
    sources[:paths][:validation] = "lib/#{opts.applet}/validations/#{opts.singlename}_schema.rb"
    sources[:paths][:route] = "routes/#{opts.applet}/#{opts.program}.rb"
    sources[:paths][:uirule] = "lib/#{opts.applet}/ui_rules/#{opts.singlename}.rb"
    sources[:paths][:view] = {
                               new: "lib/#{opts.applet}/views/#{opts.singlename}/new.rb",
                               edit: "lib/#{opts.applet}/views/#{opts.singlename}/edit.rb",
                               show: "lib/#{opts.applet}/views/#{opts.singlename}/show.rb"
                             }
    report               = QueryMaker.call(opts)
    sources[:query]      = wrapped_sql_from_report(report)
    sources[:dm_query]   = DmQueryMaker.call(report, opts)
    sources[:list]       = ListMaker.call(opts)
    sources[:search]     = SearchMaker.call(opts)
    sources[:repo]       = RepoMaker.call(opts)
    sources[:entity]     = EntityMaker.call(opts)
    sources[:validation] = ValidationMaker.call(opts)
    sources[:uirule]     = UiRuleMaker.call(opts)
    sources[:view]       = ViewMaker.call(opts)
    sources[:route]      = RouteMaker.call(opts)

    if opts.new_applet
      sources[:paths][:applet] = "lib/applets/#{opts.applet}_applet.rb"
      sources[:applet]         = AppletMaker.call(opts)
    end

    sources

    # 1) use repo to get schema of table.
    # create files & dirs...
    # classes for creating each of entity, repo, ui_rule, valid, view, route
    # :: where should these classes live? >>> within service class at first...
  end

  private

  def wrapped_sql_from_report(report)
    width = 120
    ar = report.runnable_sql.gsub(/from /i, "\nFROM ").gsub(/where /i, "\nWHERE ").gsub(/(left outer join |left join |inner join |join )/i, "\n\\1").split("\n")
    ar.map { |a| a.scan(/\S.{0,#{width - 2}}\S(?=\s|$)|\S+/).join("\n") }.join("\n")
  end

  class TableMeta
    attr_reader :columns, :column_names, :foreigns, :col_lookup, :fk_lookup
    def initialize(table)
      repo          = DevelopmentRepo.new
      @columns      = repo.table_columns(table)
      @column_names = repo.table_col_names(table)
      @foreigns     = repo.foreign_keys(table)
      @col_lookup   = Hash[@columns]
      @fk_lookup    = {}
      @foreigns.each { |hs| hs[:columns].each { |c| @fk_lookup[c] = { key: hs[:key], table: hs[:table] } } }
    end

    def likely_label_field
      col_name = nil
      columns.each do |this_name, attrs|
        next if this_name == :id
        next if this_name.to_s.end_with?('_id')
        next unless attrs[:type] == :string
        col_name = this_name
        break
      end
      col_name || 'id'
    end

    def columns_without(ignore_cols)
      @column_names.reject { |c| ignore_cols.include?(c) }
    end

    def column_dry_type(column)
      case @col_lookup[column][:type]
      when :integer
        'Types::Int'
      when :string
        'Types::String'
      when :boolean
        'Types::Bool'
      when :datetime
        'Types::DateTime'
      else
        "Types::??? (#{@col_lookup[column][:type]}"
      end
    end

    def column_dry_validation_type(column)
      case @col_lookup[column][:type]
      when :integer
        ':int?'
      when :string
        ':str?'
      when :boolean
        ':bool?'
      when :datetime
        ':date_time?'
      when :date
        ':date?'
      when :time
        ':time?'
        # float? equivalent to type?(Float)
        # decimal? equivalent to type?(BigDecimal)
        # array? equivalent to type?(Array)
        # hash? equivalent to type?(Hash)
      else
        "Types::??? (#{@col_lookup[column][:type]}"
      end
    end
  end

  class RepoMaker < BaseService
    attr_reader :opts
    def initialize(opts)
      @opts = opts
    end

    def call
      <<~EOS
      # frozen_string_literal: true

      class #{opts.klassname}Repo < RepoBase
        def initialize
          main_table :#{opts.table}
          table_wrapper #{opts.klassname}#{for_select}
        end
      end
      EOS
    end

    private
    def for_select
      return nil if opts.label_field.empty?
      <<-EOS

    for_select_options label: :#{opts.label_field},
                       value: :id,
                       order_by: :#{opts.label_field}
      EOS
    end
  end

  class EntityMaker < BaseService
    attr_reader :opts
    def initialize(opts)
      @opts = opts
    end

    def call
      attr = columnise
      <<~EOS
      # frozen_string_literal: true

      class #{opts.klassname} < Dry::Struct
        #{attr.join("\n  ")}
      end
      EOS
    end

    private

    def columnise
      attr = []
      opts.table_meta.columns_without(%i{created_at updated_at}).each do |col|
        attr << "attribute :#{col}, #{opts.table_meta.column_dry_type(col)}"
      end
      attr
    end
  end

  class ValidationMaker < BaseService
    attr_reader :opts
    def initialize(opts)
      @opts = opts
    end

    def call
      attr = columnise
      <<~EOS
      # frozen_string_literal: true

      #{opts.klassname}Schema = Dry::Validation.Form do
        #{attr.join("\n  ")}
      end
      EOS
    end

    private

    def columnise
      attr = []
      opts.table_meta.columns_without(%i{created_at updated_at}).each do |col|
        detail = opts.table_meta.col_lookup[col]
        fill_opt = detail[:allow_null] ? 'maybe' : 'filled'
        max = detail[:max_length] && detail[:max_length] < 200 ? "max_size?: #{detail[:max_length]}" : nil
        rules = [opts.table_meta.column_dry_validation_type(col), max].compact.join(', ')
        if col == :id
          attr << "optional(:#{col}).#{fill_opt}(#{rules})"
        else
          attr << "required(:#{col}).#{fill_opt}(#{rules})"
        end
      end
      attr
    end
  end

  class ListMaker < BaseService
    attr_reader :opts
    def initialize(opts)
      @opts = opts
    end

    def call
      list = { dataminer_definition: opts.table }
      list[:actions] = []
      list[:actions] << { url: "/#{opts.applet}/#{opts.program}/#{opts.table}/$:id$",
                          text: 'view',
                          icon: 'fa-eye',
                          title: 'View',
                          popup: true }
      list[:actions] << { url: "/#{opts.applet}/#{opts.program}/#{opts.table}/$:id$/edit",
                          text: 'edit',
                          icon: 'fa-edit',
                          title: 'Edit',
                          popup: true }
      list[:actions] << { url: "/#{opts.applet}/#{opts.program}/#{opts.table}/$:id$",
                          text: 'delete',
                          icon: 'fa-remove',
                          is_delete: true,
                          popup: true }
      list[:page_controls] = []
      list[:page_controls] << { control_type: :link,
                                url: "/#{opts.applet}/#{opts.program}/#{opts.table}/new",
                                text: "New #{opts.singlename.split('_').map { |n| n.capitalize}.join(' ')}",
                                style: :button,
                                behaviour: :popup }
      list.to_yaml
    end
  end

  class SearchMaker < BaseService
    attr_reader :opts
    def initialize(opts)
      @opts = opts
    end

    def call
      search = { dataminer_definition: opts.table }
      search[:actions] = []
      search[:actions] << { url: "/#{opts.applet}/#{opts.program}/#{opts.table}/$:id$",
                            text: 'view',
                            icon: 'fa-eye',
                            title: 'View',
                            popup: true }
      search[:actions] << { url: "/#{opts.applet}/#{opts.program}/#{opts.table}/$:id$/edit",
                            text: 'edit',
                            icon: 'fa-edit',
                            title: 'Edit',
                            popup: true }
      search[:actions] << { url: "/#{opts.applet}/#{opts.program}/#{opts.table}/$:id$",
                            text: 'delete',
                            icon: 'fa-remove',
                            is_delete: true,
                            popup: true }
      search[:page_controls] = []
      search[:page_controls] << { control_type: :link,
                                  url: "/#{opts.applet}/#{opts.program}/#{opts.table}/new",
                                  text: "New #{opts.singlename.split('_').map { |n| n.capitalize}.join(' ')}",
                                  style: :button,
                                  behaviour: :popup }
      search.to_yaml
    end
  end

  class RouteMaker < BaseService
    attr_reader :opts
    def initialize(opts)
      @opts = opts
    end

    def call
      roda_klass    = 'Framework'
      applet_klass  = UtilityFunctions.camelize(opts.applet)
      program_klass = UtilityFunctions.camelize(opts.program)

      <<~EOS
      # frozen_string_literal: true

      class #{roda_klass} < Roda
        route '#{opts.program}', '#{opts.applet}' do |r|

          # #{opts.table.upcase.gsub('_', ' ')}
          # --------------------------------------------------------------------------
          r.on '#{opts.table}', Integer do |id|
            repo                = #{opts.klassname}Repo.new
            #{opts.singlename} = repo.find(id)

            # Check for notfound:
            r.on #{opts.singlename}.nil? do
              handle_not_found(r)
            end

            r.on 'edit' do   # EDIT
              begin
                if authorised?('#{opts.program}', 'edit')
                  show_partial { #{applet_klass}::#{program_klass}::#{opts.klassname}::Edit.call(id) }
                else
                  dialog_permission_error
                end
              rescue => e
                dialog_error(e)
              end
            end
            r.is do
              r.get do       # SHOW
                if authorised?('#{opts.program}', 'read')
                  show_partial { #{applet_klass}::#{program_klass}::#{opts.klassname}::Show.call(id) }
                else
                  dialog_permission_error
                end
              end
              r.patch do     # UPDATE
                begin
                  response['Content-Type'] = 'application/json'
                  res = #{opts.klassname}Schema.call(params[:#{opts.singlename}])
                  errors = res.messages
                  if errors.empty?
                    repo = #{opts.klassname}Repo.new
                    repo.update(id, res)
                    update_grid_row(id, changes: { #{grid_refresh_fields} },
                                        notice:  "Updated \#{res[:#{opts.label_field}]}")
                  else
                    content = show_partial { #{applet_klass}::#{program_klass}::#{opts.klassname}::Edit.call(id, params[:#{opts.singlename}], errors) }
                    update_dialog_content(content: content, error: 'Validation error')
                  end
                rescue => e
                  handle_json_error(e)
                end
              end
              r.delete do    # DELETE
                response['Content-Type'] = 'application/json'
                repo = #{opts.klassname}Repo.new
                repo.delete(id)
                delete_grid_row(id, notice: 'Deleted')
              end
            end
          end
          r.on '#{opts.table}' do
            r.on 'new' do    # NEW
              begin
                if authorised?('#{opts.program}', 'new')
                  show_partial { #{applet_klass}::#{program_klass}::#{opts.klassname}::New.call }
                else
                  dialog_permission_error
                end
              rescue => e
                dialog_error(e)
              end
            end
            r.post do        # CREATE
              res = #{opts.klassname}Schema.call(params[:#{opts.singlename}])
              errors = res.messages
              if errors.empty?
                repo = #{opts.klassname}Repo.new
                repo.create(res)
                flash[:notice] = 'Created'
                redirect_via_json_to_last_grid
              else
                content = show_partial { #{applet_klass}::#{program_klass}::#{opts.klassname}::New.call(params[:#{opts.singlename}], errors) }
                update_dialog_content(content: content, error: 'Validation error')
              end
            end
          end
        end
      end
      EOS
    end

    def grid_refresh_fields
      opts.table_meta.columns_without(%i{id created_at updated_at}).map do |col|
        "#{col}: res[:#{col}]"
      end.join(', ')
    end

  end

  class UiRuleMaker < BaseService
    attr_reader :opts
    def initialize(opts)
      @opts = opts
    end

    def call
      <<~EOS
      # frozen_string_literal: true

      module UiRules
        class #{opts.klassname} < Base
          def generate_rules
            @this_repo = #{opts.klassname}Repo.new
            make_form_object

            set_common_fields common_fields

            set_show_fields if @mode == :show

            form_name '#{opts.singlename}'.freeze
          end

          def set_show_fields
            #{show_fields.join(UtilityFunctions.newline_and_spaces(6))}
          end

          def common_fields
            {
              #{common_fields.join(UtilityFunctions.comma_newline_and_spaces(8))}
            }
          end

          def make_form_object
            make_new_form_object && return if @mode == :new

            @form_object = @this_repo.find(@options[:id])
          end

          def make_new_form_object
            @form_object = OpenStruct.new(#{struct_fields.join(UtilityFunctions.comma_newline_and_spaces(36))})
          end
        end
      end
      EOS
    end

    private

    def fields_to_use
      opts.table_meta.columns_without(%i{id created_at updated_at})
    end

    def show_fields
      flds = []
      fields_to_use.each do |f|
        fk = opts.table_meta.fk_lookup[f]
        if fk
          tm = TableMeta.new(fk[:table])
          singlename  = UtilityFunctions.simple_single(fk[:table].to_s)
          klassname   = UtilityFunctions.camelize(singlename)
          fk_repo = "#{klassname}Repo"
          code = tm.likely_label_field
          flds << "#{f}_label = #{fk_repo}.new.find(@form_object.#{f})&.#{code}"
        end
      end

      flds + fields_to_use.map do |f|
        fk = opts.table_meta.fk_lookup[f]
        if fk.nil?
          "fields[:#{f}] = { renderer: :label }"
        else
          "fields[:#{f}] = { renderer: :label, with_value: #{f}_label }"
        end
      end # can be more intelligent for foreign keys...
    end

    def common_fields # bool == checkbox, fk == select etc
      fields_to_use.map do |field|
        this_col = opts.table_meta.col_lookup[field]
        if this_col.nil?
          "#{field}: {}"
        elsif this_col[:type] == :boolean #int: number, _id: select.
          "#{field}: { renderer: :checkbox }"
        elsif field.to_s.end_with?('_id')
          make_select(field, this_col)
        else
          "#{field}: {}"
        end
      end
    end

    def make_select(field, col)
      fk = opts.table_meta.fk_lookup[field]
      return "#{field}: {}" if fk.nil?
      singlename  = UtilityFunctions.simple_single(fk[:table].to_s)
      klassname   = UtilityFunctions.camelize(singlename)
      fk_repo = "#{klassname}Repo"
      # get fk data & make select - or (if no fk....)
      "#{field}: { renderer: :select, options: #{fk_repo}.new.for_select }"
    end

    def struct_fields # use default values (or should the use of struct be changed to something that knows the db?)
      fields_to_use.map do |field|
        this_col = opts.table_meta.col_lookup[field]
        if this_col && this_col[:default]
          "#{field}: #{this_col[:default]}" # might need to be in quotes...
        else
          "#{field}: nil"
        end
      end
    end
  end

  class ViewMaker < BaseService
    attr_reader :opts
    def initialize(opts)
      @opts = opts
    end

    def call
      {
        new: new_view,
        edit: edit_view,
        show: show_view
      }
    end

    private

    def fields_to_use
      opts.table_meta.columns_without(%i{id created_at updated_at})
    end

    def form_fields
      fields_to_use.map { |f| "form.add_field :#{f}" }.join(UtilityFunctions.newline_and_spaces(14))
    end

    def new_view
      applet_klass  = UtilityFunctions.camelize(opts.applet)
      program_klass = UtilityFunctions.camelize(opts.program)
      <<~EOS
      # frozen_string_literal: true

      module #{applet_klass}
        module #{program_klass}
          module #{opts.klassname}
            class New
              def self.call(form_values = nil, form_errors = nil)
                ui_rule = UiRules::Compiler.new(:#{opts.singlename}, :new)
                rules   = ui_rule.compile

                layout = Crossbeams::Layout::Page.build(rules) do |page|
                  page.form_object ui_rule.form_object
                  page.form_values form_values
                  page.form_errors form_errors
                  page.form do |form|
                    form.action '/#{opts.applet}/#{opts.program}/#{opts.table}'
                    form.remote!
                    #{form_fields}
                  end
                end

                layout
              end
            end
          end
        end
      end
      EOS
    end

    def edit_view
      applet_klass  = UtilityFunctions.camelize(opts.applet)
      program_klass = UtilityFunctions.camelize(opts.program)
      <<~EOS
      # frozen_string_literal: true

      module #{applet_klass}
        module #{program_klass}
          module #{opts.klassname}
            class Edit
              def self.call(id, form_values = nil, form_errors = nil)
                ui_rule = UiRules::Compiler.new(:#{opts.singlename}, :edit, id: id)
                rules   = ui_rule.compile

                layout = Crossbeams::Layout::Page.build(rules) do |page|
                  page.form_object ui_rule.form_object
                  page.form_values form_values
                  page.form_errors form_errors
                  page.form do |form|
                    form.action "/#{opts.applet}/#{opts.program}/#{opts.table}/\#{id}"
                    form.remote!
                    form.method :update
                    #{form_fields}
                  end
                end

                layout
              end
            end
          end
        end
      end
      EOS
    end

    def show_view
      applet_klass  = UtilityFunctions.camelize(opts.applet)
      program_klass = UtilityFunctions.camelize(opts.program)
      <<~EOS
      # frozen_string_literal: true

      module #{applet_klass}
        module #{program_klass}
          module #{opts.klassname}
            class Show
              def self.call(id)
                ui_rule = UiRules::Compiler.new(:#{opts.singlename}, :show, id: id)
                rules   = ui_rule.compile

                layout = Crossbeams::Layout::Page.build(rules) do |page|
                  page.form_object ui_rule.form_object
                  page.form do |form|
                    form.view_only!
                    #{form_fields}
                  end
                end

                layout
              end
            end
          end
        end
      end
      EOS
    end
  end

  class QueryMaker < BaseService
    attr_reader :opts
    def initialize(opts)
      @opts = opts
      @repo = DevelopmentRepo.new
    end

    def call
      base_sql = <<~EOS
      SELECT #{columns}
      FROM #{opts.table}
      #{make_joins}
      EOS
      report = Crossbeams::Dataminer::Report.new(opts.table.split('_').map { |w| w.capitalize }.join(' '))
      report.sql = base_sql
      report
    end

    private

    def columns
      tab_cols = opts.table_meta.column_names.map { |col| "#{opts.table}.#{col}" }
      fk_cols  = []
      opts.table_meta.foreigns.each do |fk|
        if fk[:table] == :party_roles # Special treatment for party_lore lookups to get party name
          fk[:columns].each do |fk_col|
            fk_cols << "fn_party_role_name(#{opts.table}.#{fk_col}) AS #{fk_col.sub(/_id$/, '')}"
          end
        else
          fk_col = get_representative_col_from_table(fk[:table])
          if opts.table_meta.column_names.include?(fk_col.to_sym)
            fk_cols << "#{fk[:table]}.#{fk_col} AS #{fk[:table]}_#{fk_col}"
          else
            fk_cols << "#{fk[:table]}.#{fk_col}"
          end
        end
      end
      (tab_cols + fk_cols).join(', ')
    end

    def get_representative_col_from_table(table)
      tab = TableMeta.new(table)
      tab.likely_label_field
    end

    def make_joins
      used_tables = Hash.new(0)
      opts.table_meta.foreigns.map do |fk|
        tab_alias = fk[:table]
        next if tab_alias == :party_roles # No join - usualy no need to join if using fn_party_role_name() function for party name
        cnt       = used_tables[fk[:table]] += 1
        tab_alias = "#{tab_alias}#{cnt}" if cnt > 1
        on_str    = make_on_clause(tab_alias, fk[:key], fk[:columns])
        out_join = nullable_column?(fk[:columns].first) ? 'LEFT ' : ''
        "#{out_join}JOIN #{fk[:table]} #{cnt > 1 ? tab_alias : ''} #{on_str}"
      end.join("\n")
    end

    def make_on_clause(tab_alias, keys, cols)
      res = []
      keys.each_with_index do |k, i|
        res << "#{i.zero? ? 'ON' : 'AND'} #{tab_alias}.#{k} = #{opts.table}.#{cols[i]}"
      end
      res.join("\n")
    end

    def nullable_column?(column)
      opts.table_meta.col_lookup[column][:allow_null]
    end
  end

  class DmQueryMaker < BaseService
    attr_reader :opts, :report
    def initialize(report, opts)
      @report = Crossbeams::Dataminer::Report.new(report.caption)
      @report.sql = report.runnable_sql
      @opts   = opts
    end

    def call
      new_report = Crossbeams::DataminerInterface::DmCreator.new(DB, report).modify_column_datatypes
      hide_cols = %w{id created_at updated_at}
      new_report.ordered_columns.each do |col|
        new_report.column(col.name).hide = true if hide_cols.include?(col.name) || col.name.end_with?('_id')
      end
      new_report.to_hash.to_yaml
    end
  end
  # service?

  class AppletMaker < BaseService
    attr_reader :opts
    def initialize(opts)
      @opts   = opts
    end

    def call
      <<~EOS
      # frozen_string_literal: true

      Dir['./lib/#{opts.applet}/entities/*.rb'].each { |f| require f }
      Dir['./lib/#{opts.applet}/repositories/*.rb'].each { |f| require f }
      # Dir['./lib/#{opts.applet}/services/*.rb'].each { |f| require f }
      Dir['./lib/#{opts.applet}/ui_rules/*.rb'].each { |f| require f }
      Dir['./lib/#{opts.applet}/validations/*.rb'].each { |f| require f }
      Dir['./lib/#{opts.applet}/views/**/*.rb'].each { |f| require f }
      EOS
    end
  end
end
