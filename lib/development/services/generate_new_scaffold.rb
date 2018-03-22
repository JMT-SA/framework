# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize

class GenerateNewScaffold < BaseService
  include UtilityFunctions
  attr_accessor :opts

  # >>> check yml popup on delete requirements
  # TODO: dry-validation: type to pre-strip strings...
  def initialize(params)
    @opts             = OpenStruct.new(params)
    @opts.new_applet  = @opts.applet == 'other'
    @opts.applet      = params[:other] if @opts.applet == 'other'
    @opts.applet_module = "#{@opts.applet.split('_').map(&:capitalize).join}App"
    @opts.program   ||= 'progname'
    @opts.singlename  = simple_single(@opts.short_name)
    @opts.klassname   = camelize(@opts.singlename)
    @opts.query_name  = params[:query_name]  || @opts.table
    @opts.list_name   = params[:list_name]   || @opts.table
    @opts.search_name = params[:search_name] || @opts.table
    @opts.label_field = params[:label_field]
    @opts.table_meta  = TableMeta.new(@opts.table)
    @opts.label_field = @opts.table_meta.likely_label_field if @opts.label_field.nil?
  end

  def call
    sources = { opts: opts, paths: {} }
    sources[:paths][:dm_query] = "grid_definitions/dataminer_queries/#{opts.table}.yml"
    sources[:paths][:list] = "grid_definitions/lists/#{opts.table}.yml"
    sources[:paths][:search] = "grid_definitions/searches/#{opts.table}.yml"
    sources[:paths][:repo] = "lib/#{opts.applet}/repositories/#{opts.singlename}_repo.rb"
    sources[:paths][:inter] = "lib/#{opts.applet}/interactors/#{opts.singlename}_interactor.rb"
    sources[:paths][:entity] = "lib/#{opts.applet}/entities/#{opts.singlename}.rb"
    sources[:paths][:validation] = "lib/#{opts.applet}/validations/#{opts.singlename}_schema.rb"
    sources[:paths][:route] = "routes/#{opts.applet}/#{opts.program}.rb"
    sources[:paths][:uirule] = "lib/#{opts.applet}/ui_rules/#{opts.singlename}_rule.rb"
    sources[:paths][:view] = {
      new: "lib/#{opts.applet}/views/#{opts.singlename}/new.rb",
      edit: "lib/#{opts.applet}/views/#{opts.singlename}/edit.rb",
      show: "lib/#{opts.applet}/views/#{opts.singlename}/show.rb"
    }
    sources[:paths][:test] = {
      interactor: "lib/#{opts.applet}/test/interactors/test_#{opts.singlename}_interactor.rb",
      repo: "lib/#{opts.applet}/test/repositories/test_#{opts.singlename}_repo.rb",
      route: "test/routes/test_#{opts.singlename}_routes.rb"
    }
    report               = QueryMaker.call(opts)
    sources[:query]      = wrapped_sql_from_report(report)
    sources[:dm_query]   = DmQueryMaker.call(report, opts)
    sources[:list]       = ListMaker.call(opts)
    sources[:search]     = SearchMaker.call(opts)
    sources[:repo]       = RepoMaker.call(opts)
    sources[:entity]     = EntityMaker.call(opts)
    sources[:inter]      = InteractorMaker.call(opts)
    sources[:validation] = ValidationMaker.call(opts)
    sources[:uirule]     = UiRuleMaker.call(opts)
    sources[:view]       = ViewMaker.call(opts)
    sources[:route]      = RouteMaker.call(opts)
    sources[:menu]       = MenuMaker.call(opts)
    sources[:test]       = TestMaker.call(opts)

    if opts.new_applet
      sources[:paths][:applet] = "lib/applets/#{opts.applet}_applet.rb"
      sources[:applet]         = AppletMaker.call(opts)
    end

    sources
  end

  private

  def wrapped_sql_from_report(report)
    width = 120
    ar = report.runnable_sql.gsub(/from /i, "\nFROM ").gsub(/where /i, "\nWHERE ").gsub(/(left outer join |left join |inner join |join )/i, "\n\\1").split("\n")
    ar.map { |a| a.scan(/\S.{0,#{width - 2}}\S(?=\s|$)|\S+/).join("\n") }.join("\n")
  end

  class TableMeta
    attr_reader :columns, :column_names, :foreigns, :col_lookup, :fk_lookup, :indexed_columns

    DRY_TYPE_LOOKUP = {
      integer: 'Types::Int',
      string: 'Types::String',
      boolean: 'Types::Bool',
      float: 'Types::Float',
      datetime: 'Types::DateTime',
      integer_array: 'Types::Array',
      string_array: 'Types::Array'
    }.freeze

    VALIDATION_TYPE_LOOKUP = {
      integer: '(:int?)',
      string: '(:str?)',
      boolean: '(:bool?)',
      datetime: '(:date_time?)',
      date: '(:date?)',
      time: '(:time?)',
      float: '(:float?)',
      integer_array: ' { each(:int?) }',
      string_array: ' { each(:str?) }'
    }.freeze

    def initialize(table)
      repo             = DevelopmentRepo.new
      @columns         = repo.table_columns(table)
      @column_names    = repo.table_col_names(table)
      @indexed_columns = repo.indexed_columns(table)
      @foreigns        = repo.foreign_keys(table)
      @col_lookup      = Hash[@columns]
      @fk_lookup       = {}
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
      DRY_TYPE_LOOKUP[@col_lookup[column][:type]] || "Types::??? (#{@col_lookup[column][:type]})"
    end

    def column_dry_validation_type(column)
      VALIDATION_TYPE_LOOKUP[@col_lookup[column][:type]] || "(Types::??? (#{@col_lookup[column][:type]}))"
    end

    def active_column_present?
      @column_names.include?(:active)
    end
  end

  class InteractorMaker < BaseService
    attr_reader :opts
    def initialize(opts)
      @opts = opts
    end

    def call
      <<~RUBY
        # frozen_string_literal: true

        module #{opts.applet_module}
          class #{opts.klassname}Interactor < BaseInteractor
            def repo
              @repo ||= #{opts.klassname}Repo.new
            end

            def #{opts.singlename}(cached = true)
              if cached
                @#{opts.singlename} ||= repo.find_#{opts.singlename}(@id)
              else
                @#{opts.singlename} = repo.find_#{opts.singlename}(@id)
              end
            end

            def validate_#{opts.singlename}_params(params)
              #{opts.klassname}Schema.call(params)
            end

            def create_#{opts.singlename}(params)
              res = validate_#{opts.singlename}_params(params)
              return validation_failed_response(res) unless res.messages.empty?
              @id = repo.create_#{opts.singlename}(res)
              success_response("Created #{opts.singlename.tr('_', ' ')} \#{#{opts.singlename}.#{opts.label_field}}",
                               #{opts.singlename})
            rescue Sequel::UniqueConstraintViolation
              validation_failed_response(OpenStruct.new(messages: { #{opts.label_field}: ['This #{opts.singlename.tr('_', ' ')} already exists'] }))
            end

            def update_#{opts.singlename}(id, params)
              @id = id
              res = validate_#{opts.singlename}_params(params)
              return validation_failed_response(res) unless res.messages.empty?
              repo.update_#{opts.singlename}(id, res)
              success_response("Updated #{opts.singlename.tr('_', ' ')} \#{#{opts.singlename}.#{opts.label_field}}",
                               #{opts.singlename}(false))
            end

            def delete_#{opts.singlename}(id)
              @id = id
              name = #{opts.singlename}.#{opts.label_field}
              repo.delete_#{opts.singlename}(id)
              success_response("Deleted #{opts.singlename.tr('_', ' ')} \#{name}")
            end
          end
        end
      RUBY
    end
  end

  class RepoMaker < BaseService
    attr_reader :opts
    def initialize(opts)
      @opts = opts
    end

    def call
      if @opts.table_meta.active_column_present?
        <<~RUBY
          # frozen_string_literal: true

          module #{opts.applet_module}
            class #{opts.klassname}Repo < RepoBase
              build_for_select :#{opts.table},
                               label: :#{opts.label_field},
                               value: :id,
                               order_by: :#{opts.label_field}
              build_inactive_select :#{opts.table},
                                    label: :#{opts.label_field},
                                    value: :id,
                                    order_by: :#{opts.label_field}

              crud_calls_for :#{opts.table}, name: :#{opts.singlename}, wrapper: #{opts.klassname}
            end
          end
        RUBY
      else
        <<~RUBY
          # frozen_string_literal: true

          module #{opts.applet_module}
            class #{opts.klassname}Repo < RepoBase
              build_for_select :#{opts.table},
                               label: :#{opts.label_field},
                               value: :id,
                               no_active_check: true,
                               order_by: :#{opts.label_field}

              crud_calls_for :#{opts.table}, name: :#{opts.singlename}, wrapper: #{opts.klassname}
            end
          end
        RUBY
      end
    end
  end

  class EntityMaker < BaseService
    attr_reader :opts
    def initialize(opts)
      @opts = opts
    end

    def call
      attr = columnise
      <<~RUBY
        # frozen_string_literal: true

        module #{opts.applet_module}
          class #{opts.klassname} < Dry::Struct
            #{attr.join("\n    ")}
          end
        end
      RUBY
    end

    private

    def columnise
      attr = []
      opts.table_meta.columns_without(%i[created_at updated_at active]).each do |col|
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
      <<~RUBY
        # frozen_string_literal: true

        module #{opts.applet_module}
          #{opts.klassname}Schema = Dry::Validation.Form do
            #{attr.join("\n    ")}
          end
        end
      RUBY
    end

    private

    def columnise
      attr = []
      opts.table_meta.columns_without(%i[created_at updated_at active]).each do |col|
        detail = opts.table_meta.col_lookup[col]
        fill_opt = detail[:allow_null] ? 'maybe' : 'filled'
        max = detail[:max_length] && detail[:max_length] < 200 ? "max_size?: #{detail[:max_length]}" : nil
        rules = [opts.table_meta.column_dry_validation_type(col), max].compact.join(', ')
        attr << if col == :id
                  "optional(:#{col}).#{fill_opt}#{rules}"
                else
                  "required(:#{col}).#{fill_opt}#{rules}"
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
                                text: "New #{opts.singlename.split('_').map(&:capitalize).join(' ')}",
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
                                  text: "New #{opts.singlename.split('_').map(&:capitalize).join(' ')}",
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
      <<~RUBY
        # frozen_string_literal: true

        # rubocop:disable Metrics/ClassLength
        # rubocop:disable Metrics/BlockLength

        class #{roda_klass} < Roda
          route '#{opts.program}', '#{opts.applet}' do |r|
            # #{opts.table.upcase.tr('_', ' ')}
            # --------------------------------------------------------------------------
            r.on '#{opts.table}', Integer do |id|
              interactor = #{opts.applet_module}::#{opts.klassname}Interactor.new(current_user, {}, {}, {})

              # Check for notfound:
              r.on !interactor.exists?(:#{opts.table}, id) do
                handle_not_found(r)
              end

              r.on 'edit' do   # EDIT
                if authorised?('#{opts.program}', 'edit')
                  show_partial { #{applet_klass}::#{program_klass}::#{opts.klassname}::Edit.call(id) }
                else
                  dialog_permission_error
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
                  response['Content-Type'] = 'application/json'
                  res = interactor.update_#{opts.singlename}(id, params[:#{opts.singlename}])
                  if res.success
                    update_grid_row(id, changes: { #{grid_refresh_fields} },
                                    notice: res.message)
                  else
                    content = show_partial { #{applet_klass}::#{program_klass}::#{opts.klassname}::Edit.call(id, params[:#{opts.singlename}], res.errors) }
                    update_dialog_content(content: content, error: res.message)
                  end
                end
                r.delete do    # DELETE
                  response['Content-Type'] = 'application/json'
                  res = interactor.delete_#{opts.singlename}(id)
                  delete_grid_row(id, notice: res.message)
                end
              end
            end
            r.on '#{opts.table}' do
              interactor = #{opts.applet_module}::#{opts.klassname}Interactor.new(current_user, {}, {}, {})
              r.on 'new' do    # NEW
                if authorised?('#{opts.program}', 'new')
                  page = stashed_page
                  if page
                    show_page { page }
                  else
                    show_partial_or_page(fetch?(r)) { #{applet_klass}::#{program_klass}::#{opts.klassname}::New.call(remote: fetch?(r)) }
                  end
                else
                  fetch?(r) ? dialog_permission_error : show_unauthorised
                end
              end
              r.post do        # CREATE
                res = interactor.create_#{opts.singlename}(params[:#{opts.singlename}])
                if res.success
                  flash[:notice] = res.message
                  if fetch?(r)
                    redirect_via_json_to_last_grid
                  else
                    redirect_to_last_grid(r)
                  end
                elsif fetch?(r)
                  content = show_partial do
                    #{applet_klass}::#{program_klass}::#{opts.klassname}::New.call(form_values: params[:#{opts.singlename}],
                    #{UtilityFunctions.spaces_from_string_lengths(15, applet_klass, program_klass, opts.klassname)}form_errors: res.errors,
                    #{UtilityFunctions.spaces_from_string_lengths(15, applet_klass, program_klass, opts.klassname)}remote: true)
                  end
                  update_dialog_content(content: content, error: res.message)
                else
                  flash[:error] = res.message
                  stash_page(#{applet_klass}::#{program_klass}::#{opts.klassname}::New.call(form_values: params[:#{opts.singlename}],
                             #{UtilityFunctions.spaces_from_string_lengths(15, applet_klass, program_klass, opts.klassname)}form_errors: res.errors,
                             #{UtilityFunctions.spaces_from_string_lengths(15, applet_klass, program_klass, opts.klassname)}remote: false))
                  r.redirect '/#{opts.applet}/#{opts.program}/#{opts.table}/new'
                end
              end
            end
          end
        end
      RUBY
    end

    def grid_refresh_fields
      opts.table_meta.columns_without(%i[id created_at updated_at]).map do |col|
        "#{col}: res.instance[:#{col}]"
      end.join(', ')
    end
  end

  class UiRuleMaker < BaseService
    attr_reader :opts
    def initialize(opts)
      @opts = opts
    end

    def call
      <<~RUBY
        # frozen_string_literal: true

        module UiRules
          class #{opts.klassname}Rule < Base
            def generate_rules
              @repo = #{opts.applet_module}::#{opts.klassname}Repo.new
              make_form_object
              apply_form_values

              common_values_for_fields common_fields

              set_show_fields if @mode == :show

              form_name '#{opts.singlename}'
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

              @form_object = @repo.find_#{opts.singlename}(@options[:id])
            end

            def make_new_form_object
              @form_object = OpenStruct.new(#{struct_fields.join(UtilityFunctions.comma_newline_and_spaces(36))})
            end
          end
        end
      RUBY
    end

    private

    def fields_to_use
      opts.table_meta.columns_without(%i[id created_at updated_at active])
    end

    def show_fields
      flds = []
      fields_to_use.each do |f|
        fk = opts.table_meta.fk_lookup[f]
        next unless fk
        tm = TableMeta.new(fk[:table])
        singlename  = UtilityFunctions.simple_single(fk[:table].to_s)
        klassname   = UtilityFunctions.camelize(singlename)
        fk_repo = "#{klassname}Repo"
        code = tm.likely_label_field
        flds << "# #{f}_label = #{fk_repo}.new.find_#{singlename}(@form_object.#{f})&.#{code}"
        flds << "#{f}_label = @repo.find(:#{fk[:table]}, #{klassname}, @form_object.#{f})&.#{code}"
      end

      flds + fields_to_use.map do |f|
        fk = opts.table_meta.fk_lookup[f]
        if fk.nil?
          "fields[:#{f}] = { renderer: :label }"
        else
          "fields[:#{f}] = { renderer: :label, with_value: #{f}_label, caption: '#{f.to_s.chomp('_id')}' }"
        end
      end
    end

    # bool == checkbox, fk == select etc
    def common_fields
      fields_to_use.map do |field|
        this_col = opts.table_meta.col_lookup[field]
        if this_col.nil?
          "#{field}: {}"
        elsif this_col[:type] == :boolean # int: number, _id: select.
          "#{field}: { renderer: :checkbox }"
        elsif field.to_s.end_with?('_id')
          make_select(field)
        else
          "#{field}: {}"
        end
      end
    end

    def make_select(field)
      fk = opts.table_meta.fk_lookup[field]
      return "#{field}: {}" if fk.nil?
      singlename  = UtilityFunctions.simple_single(fk[:table].to_s)
      klassname   = UtilityFunctions.camelize(singlename)
      fk_repo = "#{klassname}Repo"
      # get fk data & make select - or (if no fk....)
      tm = TableMeta.new(fk[:table])
      if tm.active_column_present?
        "#{field}: { renderer: :select, options: #{fk_repo}.new.for_select_#{fk[:table]}, disabled_options: #{fk_repo}.new.for_inactive_select_#{fk[:table]}, caption: '#{field.to_s.chomp('_id')}' }"
      else
        "#{field}: { renderer: :select, options: #{fk_repo}.new.for_select_#{fk[:table]}, caption: '#{field.to_s.chomp('_id')}' }"
      end
    end

    # use default values (or should the use of struct be changed to something that knows the db?)
    def struct_fields
      fields_to_use.map do |field|
        this_col = opts.table_meta.col_lookup[field]
        if this_col && this_col[:ruby_default]
          "#{field}: #{default_to_string(this_col[:ruby_default])}"
        else
          "#{field}: nil"
        end
      end
    end

    def default_to_string(default)
      default.is_a?(String) ? "'#{default}'" : default
    end
  end

  class TestMaker < BaseService
    attr_reader :opts
    def initialize(opts)
      @opts = opts
    end

    def call
      {
        interactor: test_interactor,
        repo: test_repo,
        route: test_route
      }
    end

    private

    def test_repo
      <<~RUBY
        # frozen_string_literal: true

        require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

        # rubocop:disable Metrics/ClassLength
        # rubocop:disable Metrics/AbcSize

        module #{opts.applet_module}
          class Test#{opts.klassname}Repo < MiniTestWithHooks

            def test_for_selects
              assert_respond_to repo, :for_select_#{opts.table}
            end

            def test_crud_calls
              assert_respond_to repo, :find_#{opts.singlename}
              assert_respond_to repo, :create_#{opts.singlename}
              assert_respond_to repo, :update_#{opts.singlename}
              assert_respond_to repo, :delete_#{opts.singlename}
            end

            private

            def repo
              #{opts.klassname}Repo.new
            end
          end
        end
        # rubocop:enable Metrics/ClassLength
        # rubocop:enable Metrics/AbcSize
      RUBY
    end

    def test_interactor
      <<~RUBY
        # frozen_string_literal: true

        require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

        # rubocop:disable Metrics/ClassLength
        # rubocop:disable Metrics/AbcSize

        module #{opts.applet_module}
          class Test#{opts.klassname}Interactor < Minitest::Test
            def test_repo
              repo = interactor.repo
              # repo = interactor.send(:repo)
              assert repo.is_a?(#{opts.applet_module}::#{opts.klassname}Repo)
            end

            private

            def interactor
              @interactor ||= #{opts.klassname}Interactor.new(current_user, {}, {}, {})
            end
          end
        end
        # rubocop:enable Metrics/ClassLength
        # rubocop:enable Metrics/AbcSize
      RUBY
    end

    def test_route
      base_route    = "#{opts.applet}/#{opts.program}/"
      applet_klass  = UtilityFunctions.camelize(opts.applet)
      program_klass = UtilityFunctions.camelize(opts.program)
      <<~RUBY
        # frozen_string_literal: true

        require File.join(File.expand_path('./../../', __FILE__), 'test_helper_for_routes')

        class Test#{opts.klassname}Routes < RouteTester
          def around
            #{opts.applet_module}::#{opts.klassname}Interactor.any_instance.stubs(:exists?).returns(true)
            super
          end

          def test_edit
            #{applet_klass}::#{program_klass}::#{opts.klassname}::Edit.stub(:call, bland_page) do
              get '#{base_route}#{opts.table}/1/edit', {}, 'rack.session' => { user_id: 1 }
            end
            expect_bland_page
          end

          def test_edit_fail
            authorise_fail!
            get '#{base_route}#{opts.table}/1/edit', {}, 'rack.session' => { user_id: 1 }
            expect_permission_error
          end

          def test_show
            #{applet_klass}::#{program_klass}::#{opts.klassname}::Show.stub(:call, bland_page) do
              get '#{base_route}#{opts.table}/1', {}, 'rack.session' => { user_id: 1 }
            end
            expect_bland_page
          end

          def test_show_fail
            authorise_fail!
            get '#{base_route}#{opts.table}/1', {}, 'rack.session' => { user_id: 1 }
            refute last_response.ok?
            assert_match(/permission/i, last_response.body)
          end

          def test_update
            row_vals = Hash.new(1)
            #{opts.applet_module}::#{opts.klassname}Interactor.any_instance.stubs(:update_#{opts.singlename}).returns(ok_response(instance: row_vals))
            patch '#{base_route}#{opts.table}/1', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
            expect_json_update_grid
          end

          def test_update_fail
            #{opts.applet_module}::#{opts.klassname}Interactor.any_instance.stubs(:update_#{opts.singlename}).returns(bad_response)
            #{applet_klass}::#{program_klass}::#{opts.klassname}::Edit.stub(:call, bland_page) do
              patch '#{base_route}#{opts.table}/1', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
            end
            expect_json_replace_dialog(has_error: true)
          end

          def test_delete
            #{opts.applet_module}::#{opts.klassname}Interactor.any_instance.stubs(:delete_#{opts.singlename}).returns(ok_response)
            delete '#{base_route}#{opts.table}/1', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
            expect_json_delete_from_grid
          end
          #
          # def test_delete_fail
          #   #{opts.applet_module}::#{opts.klassname}Interactor.any_instance.stubs(:delete_#{opts.singlename}).returns(bad_response)
          #   delete '#{base_route}#{opts.table}/1', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
          #   expect_bad_redirect
          # end

          def test_new
            #{applet_klass}::#{program_klass}::#{opts.klassname}::New.stub(:call, bland_page) do
              get  '#{base_route}#{opts.table}/new', {}, 'rack.session' => { user_id: 1 }
            end
            expect_bland_page
          end

          def test_new_fail
            authorise_fail!
            get '#{base_route}#{opts.table}/new', {}, 'rack.session' => { user_id: 1 }
            refute last_response.ok?
            assert_match(/permission/i, last_response.body)
          end

          def test_create
            #{opts.applet_module}::#{opts.klassname}Interactor.any_instance.stubs(:create_#{opts.singlename}).returns(ok_response)
            post '#{base_route}#{opts.table}', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
            expect_ok_redirect
          end

          def test_create_remotely
            #{opts.applet_module}::#{opts.klassname}Interactor.any_instance.stubs(:create_#{opts.singlename}).returns(ok_response)
            post_as_fetch '#{base_route}#{opts.table}', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
            expect_ok_json_redirect
          end

          def test_create_fail
            #{opts.applet_module}::#{opts.klassname}Interactor.any_instance.stubs(:create_#{opts.singlename}).returns(bad_response)
            #{applet_klass}::#{program_klass}::#{opts.klassname}::New.stub(:call, bland_page) do
              post '#{base_route}#{opts.table}', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
            end
            expect_bad_redirect(url: '/#{base_route}#{opts.table}/new')
          end

          def test_create_remotely_fail
            #{opts.applet_module}::#{opts.klassname}Interactor.any_instance.stubs(:create_#{opts.singlename}).returns(bad_response)
            #{applet_klass}::#{program_klass}::#{opts.klassname}::New.stub(:call, bland_page) do
              post_as_fetch '#{base_route}#{opts.table}', {}, 'rack.session' => { user_id: 1, last_grid_url: '/' }
            end
            expect_json_replace_dialog
          end
        end
      RUBY
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
      opts.table_meta.columns_without(%i[id created_at updated_at active])
    end

    def form_fields
      fields_to_use.map { |f| "form.add_field :#{f}" }.join(UtilityFunctions.newline_and_spaces(14))
    end

    def new_view
      applet_klass  = UtilityFunctions.camelize(opts.applet)
      program_klass = UtilityFunctions.camelize(opts.program)
      <<~RUBY
        # frozen_string_literal: true

        module #{applet_klass}
          module #{program_klass}
            module #{opts.klassname}
              class New
                def self.call(form_values: nil, form_errors: nil, remote: true) # rubocop:disable Metrics/AbcSize
                  ui_rule = UiRules::Compiler.new(:#{opts.singlename}, :new, form_values: form_values)
                  rules   = ui_rule.compile

                  layout = Crossbeams::Layout::Page.build(rules) do |page|
                    page.form_object ui_rule.form_object
                    page.form_values form_values
                    page.form_errors form_errors
                    page.form do |form|
                      form.action '/#{opts.applet}/#{opts.program}/#{opts.table}'
                      form.remote! if remote
                      #{form_fields}
                    end
                  end

                  layout
                end
              end
            end
          end
        end
      RUBY
    end

    def edit_view
      applet_klass  = UtilityFunctions.camelize(opts.applet)
      program_klass = UtilityFunctions.camelize(opts.program)
      <<~RUBY
        # frozen_string_literal: true

        module #{applet_klass}
          module #{program_klass}
            module #{opts.klassname}
              class Edit
                def self.call(id, form_values = nil, form_errors = nil) # rubocop:disable Metrics/AbcSize
                  ui_rule = UiRules::Compiler.new(:#{opts.singlename}, :edit, id: id, form_values: form_values)
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
      RUBY
    end

    def show_view
      applet_klass  = UtilityFunctions.camelize(opts.applet)
      program_klass = UtilityFunctions.camelize(opts.program)
      <<~RUBY
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
      RUBY
    end
  end

  class QueryMaker < BaseService
    attr_reader :opts
    def initialize(opts)
      @opts = opts
      @repo = DevelopmentRepo.new
    end

    def call
      base_sql = <<~SQL
        SELECT #{columns}
        FROM #{opts.table}
        #{make_joins}
      SQL
      report = Crossbeams::Dataminer::Report.new(opts.table.split('_').map(&:capitalize).join(' '))
      report.sql = base_sql
      report
    end

    private

    def columns
      tab_cols = opts.table_meta.column_names.map { |col| "#{opts.table}.#{col}" }
      fk_cols  = []
      opts.table_meta.foreigns.each do |fk|
        if fk[:table] == :party_roles # Special treatment for party_role lookups to get party name
          fk[:columns].each do |fk_col|
            fk_cols << "fn_party_role_name(#{opts.table}.#{fk_col}) AS #{fk_col.sub(/_id$/, '')}"
          end
        else
          fk_col = get_representative_col_from_table(fk[:table])
          fk_cols << if opts.table_meta.column_names.include?(fk_col.to_sym)
                       "#{fk[:table]}.#{fk_col} AS #{fk[:table]}_#{fk_col}"
                     else
                       "#{fk[:table]}.#{fk_col}"
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
      @report     = Crossbeams::Dataminer::Report.new(report.caption)
      @report.sql = report.runnable_sql
      @opts       = opts
    end

    def call
      new_report = Crossbeams::DataminerInterface::DmCreator.new(DB, report).modify_column_datatypes
      hide_cols = %w[id created_at updated_at]
      new_report.ordered_columns.each do |col|
        new_report.column(col.name).hide = true if hide_cols.include?(col.name) || col.name.end_with?('_id')
        if col.name.end_with?('_id') || opts.table_meta.indexed_columns.include?(col.name.to_sym)
          param = make_param_for(col)
          new_report.add_parameter_definition(param)
        end
      end
      new_report.to_hash.to_yaml
    end

    private

    def make_param_for(col)
      control_type = control_type_for(col)
      opts = {
        control_type: control_type,
        data_type: col.data_type,
        caption: col.caption
      }
      opts[:list_def] = make_list_def_for(col) if control_type == :list
      Crossbeams::Dataminer::QueryParameterDefinition.new(col.namespaced_name, opts)
    end

    def control_type_for(col)
      if col.name.end_with?('_id')
        if opts.table_meta.fk_lookup.empty? || opts.table_meta.fk_lookup[col.name.to_sym].nil?
          :text
        else
          :list
        end
      elsif %i[date datetime].include?(col.data_type)
        :daterange
      else
        :text
      end
    end

    def make_list_def_for(col)
      fk = opts.table_meta.fk_lookup[col.name.to_sym]
      table = fk[:table]
      key = fk[:key].first
      if table == :party_roles
        "SELECT fn_party_role_name(#{key}), #{key} FROM party_roles WHERE role_id = (SELECT id FROM roles WHERE name = 'ROLE_NAME_GOES_HERE')"
      else
        likely = get_representative_col_from_table(table)
        "SELECT #{likely}, #{key} FROM #{table} ORDER BY #{likely}"
      end
    end

    def get_representative_col_from_table(table)
      tab = TableMeta.new(table)
      tab.likely_label_field
    end
  end

  # generate a blank service?

  class AppletMaker < BaseService
    attr_reader :opts
    def initialize(opts)
      @opts = opts
    end

    def call
      <<~RUBY
        # frozen_string_literal: true

        root_dir = File.expand_path('../..', __FILE__)
        Dir["\#{root_dir}/#{opts.applet}/entities/*.rb"].each { |f| require f }
        Dir["\#{root_dir}/#{opts.applet}/interactors/*.rb"].each { |f| require f }
        Dir["\#{root_dir}/#{opts.applet}/repositories/*.rb"].each { |f| require f }
        # Dir["\#{root_dir}/#{opts.applet}/services/*.rb"].each { |f| require f }
        Dir["\#{root_dir}/#{opts.applet}/ui_rules/*.rb"].each { |f| require f }
        Dir["\#{root_dir}/#{opts.applet}/validations/*.rb"].each { |f| require f }
        Dir["\#{root_dir}/#{opts.applet}/views/**/*.rb"].each { |f| require f }

        module #{opts.applet_module}
        end
      RUBY
    end
  end

  class MenuMaker < BaseService
    attr_reader :opts
    def initialize(opts)
      @opts = opts
    end

    def call
      <<~SQL
        INSERT INTO functional_areas (functional_area_name) VALUES ('#{opts.applet}');

        INSERT INTO programs (program_name, program_sequence, functional_area_id)
        VALUES ('#{opts.program}', 1, (SELECT id FROM functional_areas WHERE functional_area_name = '#{opts.applet}'));

        -- NEW menu item
        /*
        INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
        VALUES ((SELECT id FROM programs WHERE program_name = '#{opts.program}'
                 AND functional_area_id = (SELECT id FROM functional_areas
                                           WHERE functional_area_name = '#{opts.applet}')),
                 'New #{opts.klassname}', '/#{opts.applet}/#{opts.program}/#{opts.table}/new', 1);
        */

        -- LIST menu item
        INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
        VALUES ((SELECT id FROM programs WHERE program_name = '#{opts.program}'
                 AND functional_area_id = (SELECT id FROM functional_areas
                                           WHERE functional_area_name = '#{opts.applet}')),
                 '#{opts.table.capitalize}', '/list/#{opts.list_name}', 2);

        -- SEARCH menu item
        /*
        INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
        VALUES ((SELECT id FROM programs WHERE program_name = '#{opts.program}'
                 AND functional_area_id = (SELECT id FROM functional_areas
                                           WHERE functional_area_name = '#{opts.applet}')),
                 'Search #{opts.table.capitalize}', '/search/#{opts.list_name}', 2);
        */
      SQL
    end
  end
end
