# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize

module DevelopmentApp
  class GenerateNewScaffold < BaseService
    include UtilityFunctions
    attr_accessor :opts

    class ScaffoldConfig
      attr_reader :inflector, :table, :singlename, :new_applet, :applet, :program,
                  :table_meta, :label_field, :short_name, :has_short_name, :program_text,
                  :nested_route, :new_from_menu, :text_name, :services, :jobs

      def initialize(params, roda_class_name) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
        @roda_class_name     = roda_class_name
        @inflector           = Dry::Inflector.new
        @table               = params[:table]
        @singlename          = @inflector.singularize(params[:short_name])
        @text_name           = @singlename.split('_').map { |n| @inflector.camelize(n) }.join(' ')
        @has_short_name      = params[:short_name] != params[:table]
        @applet              = params[:applet]
        @new_applet          = @applet == 'other'
        @applet              = params[:other] if @applet == 'other'
        @program_text        = params[:program].tr('_', ' ').strip
        @program             = @program_text.tr(' ', '_')
        @table_meta          = TableMeta.new(@table)
        @label_field         = params[:label_field] || @table_meta.likely_label_field
        @shared_repo_name    = params[:shared_repo_name]
        @shared_factory_name = params[:shared_factory_name]
        @nested_route        = params[:nested_route_parent].nil_or_empty? ? nil : params[:nested_route_parent]
        @new_from_menu       = params[:new_from_menu].nil? ? false : params[:new_from_menu]
        @services            = params[:services].nil_or_empty? ? [] : params[:services].split(',').map(&:strip)
        @jobs                = params[:jobs].nil_or_empty? ? [] : params[:jobs].split(',').map(&:strip)
      end

      def classnames # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
        modulename    = "#{@applet.split('_').map(&:capitalize).join}App"
        classname     = @inflector.camelize(@singlename)
        applet_klass  = @inflector.camelize(@applet)
        program_klass = @inflector.camelize(@program)
        job_classes = jobs.map { |j| class_name(j) }
        srv_classes = services.map { |j| class_name(j) }
        {
          roda_class: @roda_class_name,
          module: modulename,
          class: classname,
          applet: applet_klass,
          program: program_klass,
          text_name: @inflector.singularize(@table).split('_').map(&:capitalize).join(' '),
          schema: "#{classname}Schema",
          repo: "#{@shared_repo_name.nil? || @shared_repo_name.empty? ? classname : @inflector.camelize(@shared_repo_name.sub(/Repo$/, ''))}Repo",
          factory: "#{@shared_factory_name.nil? || @shared_factory_name.empty? ? classname : @inflector.camelize(@shared_factory_name.sub(/Factory$/, ''))}Factory",
          namespaced_repo: "#{modulename}::#{@shared_repo_name.nil? || @shared_repo_name.empty? ? classname : @inflector.camelize(@shared_repo_name.sub(/Repo$/, ''))}Repo",
          interactor: "#{classname}Interactor",
          namespaced_interactor: "#{modulename}::#{classname}Interactor",
          view_prefix: "#{applet_klass}::#{program_klass}::#{classname}",
          job_classes: job_classes,
          service_classes: srv_classes
        }
      end

      def path_name(name)
        inflector.underscore(name)
      end

      def class_name(name)
        inflector.classify(name)
      end

      def filenames
        repofile = if @shared_repo_name
                     @inflector.underscore(@shared_repo_name.sub(/Repo$/, ''))
                   else
                     @singlename
                   end
        factfile = if @shared_factory_name
                     @inflector.underscore(@shared_factory_name.sub(/Factory$/, ''))
                   else
                     @singlename
                   end
        job_paths = jobs.map { |j| "lib/#{@applet}/jobs/#{path_name(j)}.rb" }
        srv_paths = services.map { |j| "lib/#{@applet}/services/#{path_name(j)}.rb" }
        {
          applet: "lib/applets/#{@applet}_applet.rb",
          dm_query: "grid_definitions/dataminer_queries/#{@table}.yml",
          list: "grid_definitions/lists/#{@table}.yml",
          search: "grid_definitions/searches/#{@table}.yml",
          repo: "lib/#{@applet}/repositories/#{repofile}_repo.rb",
          inter: "lib/#{@applet}/interactors/#{@singlename}_interactor.rb",
          permission: "lib/#{@applet}/task_permission_checks/#{@singlename}.rb",
          entity: "lib/#{@applet}/entities/#{@singlename}.rb",
          validation: "lib/#{@applet}/validations/#{@singlename}_schema.rb",
          route: "routes/#{@applet}/#{@program}.rb",
          uirule: "lib/#{@applet}/ui_rules/#{@singlename}_rule.rb",
          view: {
            new: "lib/#{@applet}/views/#{@singlename}/new.rb",
            edit: "lib/#{@applet}/views/#{@singlename}/edit.rb",
            show: "lib/#{@applet}/views/#{@singlename}/show.rb",
            complete: "lib/#{@applet}/views/#{@singlename}/complete.rb",
            approve: "lib/#{@applet}/views/#{@singlename}/approve.rb",
            reopen: "lib/#{@applet}/views/#{@singlename}/reopen.rb"
          },
          test: {
            factory: "lib/#{@applet}/test/factories/#{factfile}_factory.rb",
            interactor: "lib/#{@applet}/test/interactors/test_#{@singlename}_interactor.rb",
            permission: "lib/#{@applet}/test/task_permission_checks/test_#{@singlename}.rb",
            repo: "lib/#{@applet}/test/repositories/test_#{repofile}_repo.rb",
            route: "test/routes/#{@applet}/#{@program}/test_#{@singlename}_routes.rb"
          },
          jobs: job_paths,
          services: srv_paths
        }
      end
    end

    # TODO: dry-validation: type to pre-strip strings...
    def initialize(params, roda_class_name)
      @opts = ScaffoldConfig.new(params, roda_class_name)
    end

    def call
      sources = { opts: opts, paths: @opts.filenames }

      begin
        qm                   = QueryMaker.new(opts)
        report               = qm.call
        sources[:query]      = wrapped_sql_from_report(report)
        sources[:dm_query]   = DmQueryMaker.call(report, opts)
      rescue StandardError => e
        sources[:query]      = "-- Error building report - needs tuning: #{e.message}\n\n #{wrapped_sql(qm.base_sql)}"
        sources[:dm_query]   = "Error building report: #{e.message}"
      end
      sources[:list]       = ListMaker.call(opts)
      sources[:search]     = SearchMaker.call(opts)
      sources[:repo]       = RepoMaker.call(opts)
      sources[:entity]     = EntityMaker.call(opts)
      sources[:inter]      = InteractorMaker.call(opts)
      sources[:permission] = PermissionMaker.call(opts)
      sources[:validation] = ValidationMaker.call(opts)
      sources[:uirule]     = UiRuleMaker.call(opts)
      sources[:view]       = ViewMaker.call(opts)
      sources[:route]      = RouteMaker.call(opts)
      sources[:menu]       = MenuMaker.call(opts)
      sources[:menu_mig]   = MenuMigrationMaker.call(opts)
      sources[:test]       = TestMaker.call(opts)
      sources[:applet]     = AppletMaker.call(opts) if opts.new_applet
      sources[:services]   = ServiceMaker.call(opts) unless opts.services.nil?
      sources[:jobs]       = JobMaker.call(opts) unless opts.jobs.nil?

      sources
    end

    private

    def wrapped_sql_from_report(report)
      wrapped_sql(report.runnable_sql)
    end

    def wrapped_sql(sql)
      width = 120
      ar = sql.gsub(/from /i, "\nFROM ").gsub(/where /i, "\nWHERE ").gsub(/(left outer join |left join |inner join |join )/i, "\n\\1").split("\n")
      ar.map { |a| a.scan(/\S.{0,#{width - 2}}\S(?=\s|$)|\S+/).join("\n") }.join("\n")
    end

    class TableMeta # rubocop:disable Metrics/ClassLength
      attr_reader :columns, :column_names, :foreigns, :col_lookup, :fk_lookup, :indexed_columns

      DRY_TYPE_LOOKUP = {
        integer: 'Types::Integer',
        string: 'Types::String',
        boolean: 'Types::Bool',
        float: 'Types::Float',
        datetime: 'Types::DateTime',
        date: 'Types::Date',
        decimal: 'Types::Decimal',
        integer_array: 'Types::Array',
        string_array: 'Types::Array',
        jsonb: 'Types::Hash'
      }.freeze

      DUMMY_DATA_LOOKUP = {
        integer: '1',
        string: "'ABC'",
        boolean: 'false',
        float: '1.0',
        datetime: "'2010-01-01 12:00'",
        date: "'2010-01-01'",
        decimal: '1.0',
        integer_array: '[1, 2, 3]',
        string_array: "['A', 'B', 'C']",
        jsonb: '{}'
      }.freeze

      FAKER_STRING = 'Faker::Lorem.word'
      FAKER_UNIQUE_STRING = 'Faker::Lorem.unique.word'
      FAKER_DATA_LOOKUP = {
        integer: 'Faker::Number.number(4)',
        string: 'Faker::Lorem.word',
        boolean: 'false',
        float: '1.0',
        datetime: "'2010-01-01 12:00'",
        date: "'2010-01-01'",
        decimal: 'Faker::Number.decimal',
        integer_array: 'BaseRepo.new.array_for_db_col([1, 2, 3])',
        string_array: "BaseRepo.new.array_of_text_for_db_col(['A', 'B', 'C'])",
        jsonb: '{}'
      }.freeze

      VALIDATION_EXPECT_LOOKUP = {
        integer: '(:int?)',
        string: '(:str?)',
        boolean: '(:bool?)',
        # datetime: '(:date_time?)',
        datetime: '(:time?)',
        date: '(:date?)',
        time: '(:time?)',
        float: '(:float?)',
        decimal: '(:decimal?)',
        jsonb: '(:hash?)',
        integer_array: '(:array?)', # nil, # ' { each(:int?) }',
        string_array: '(:array?)' # nil # ' { each(:str?) }'
      }.freeze

      VALIDATION_TYPE_LOOKUP = {
        integer: 'filled(:integer)',
        string: 'filled(Types::StrippedString)',
        boolean: 'filled(:bool)',
        datetime: 'filled(:time)',
        date: 'filled(:date)',
        time: 'filled(:time)',
        float: 'filled(:float)',
        decimal: 'filled(:decimal)',
        jsonb: 'filled(:hash)',
        integer_array: 'filled(:array).each(:integer)',
        string_array: 'filled(:array).each(:string)'
      }.freeze

      VALIDATION_OPTIONAL_TYPE_LOOKUP = {
        integer: 'maybe(:integer)',
        string: 'maybe(Types::StrippedString)',
        boolean: 'maybe(:bool)',
        datetime: 'maybe(:time)',
        date: 'maybe(:date)',
        time: 'maybe(:time)',
        float: 'maybe(:float)',
        decimal: 'maybe(:decimal)',
        jsonb: 'maybe(:hash)',
        integer_array: 'maybe(:array).each(:integer) # OR: maybe(:array).maybe { each(:integer) } # if param can be nil (not [])',
        string_array: 'maybe(:array).each(:string) # OR: maybe(:array).maybe { each(:string) } # if param can be nil (not [])'
      }.freeze

      def initialize(table)
        @table           = table
        repo             = DevelopmentApp::DevelopmentRepo.new
        @columns         = repo.table_columns(table)
        @column_names    = repo.table_col_names(table)
        @indexed_columns = repo.indexed_columns(table)
        @unique_columns  = repo.unique_columns(table)
        @foreigns        = repo.foreign_keys(table)
        @col_lookup      = Hash[@columns]
        @fk_lookup       = {}
        @inflector       = Dry::Inflector.new
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

      def string_field # rubocop:disable Metrics/PerceivedComplexity , Metrics/CyclomaticComplexity
        first_col = nil
        col_name = nil
        columns.each do |this_name, attrs|
          next if this_name == :id
          next if this_name.to_s.end_with?('_id')
          next unless attrs[:type] == :string

          if first_col.nil?
            first_col = this_name
          else
            col_name = this_name
            break
          end
        end
        col_name || first_col || 'id'
      end

      def columns_without(ignore_cols)
        @column_names.reject { |c| ignore_cols.include?(c) }
      end

      def column_dry_type(column)
        DRY_TYPE_LOOKUP[@col_lookup[column][:type]] || "Types::??? (#{@col_lookup[column][:type]})"
      end

      def column_dummy_data(column, faker: false, with_fk: true, type: nil)
        if column == likely_label_field
          'Faker::Lorem.unique.word'
        elsif with_fk && fk_lookup[column]
          "#{@inflector.singularize(fk_lookup[column][:table])}_id"
        elsif faker
          faker_data(column, type)
        else
          DUMMY_DATA_LOOKUP[@col_lookup[column][:type]] || "'??? (#{@col_lookup[column][:type]})'"
        end
      end

      def faker_data(column, type)
        data = FAKER_DATA_LOOKUP[type] || 'nil'
        data = FAKER_UNIQUE_STRING if data == FAKER_STRING && @unique_columns.include?(column)
        data
      end

      def column_dry_validation_type(column, max, optional = false)
        s = if optional
              VALIDATION_OPTIONAL_TYPE_LOOKUP[@col_lookup[column][:type]] || "Types::??? (#{@col_lookup[column][:type]})"
            else
              VALIDATION_TYPE_LOOKUP[@col_lookup[column][:type]] || "Types::??? (#{@col_lookup[column][:type]})"
            end

        if max
          s.sub(')', ", #{max})")
        else
          s
        end
      end
      #
      # def column_dry_validation_array_extra(column)
      #   VALIDATION_ARRAY_LOOKUP[@col_lookup[column][:type]]
      # end

      def column_dry_validation_expect_type(column)
        VALIDATION_EXPECT_LOOKUP[@col_lookup[column][:type]] || "(Types::??? (#{@col_lookup[column][:type]}))"
      end

      def active_column_present?
        @column_names.include?(:active)
      end

      def completed_column_present?
        @column_names.include?(:completed)
      end

      def approved_column_present?
        @column_names.include?(:approved)
      end

      def dependency_tree(lkp_tables = [])
        out = {}
        out[@table] = []
        columns.each do |col, attrs|
          next if attrs[:primary_key]

          hs = { name: col }.merge(attrs)
          if fk_lookup[col] && !lkp_tables.include?(fk_lookup[col][:table])
            lkp_tables << fk_lookup[col][:table]
            hs[:ftbl] = fk_lookup[col][:table]
            this_meta = TableMeta.new(fk_lookup[col][:table])
            out = out.merge(this_meta.dependency_tree(lkp_tables))
          end
          out[@table] << hs
        end
        out
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

          module #{opts.classnames[:module]}
            class #{opts.classnames[:interactor]} < BaseInteractor
              def create_#{opts.singlename}(#{needs_id}params)#{add_parent_to_params}
                res = validate_#{opts.singlename}_params(params)
                return validation_failed_response(res) if res.failure?

                id = nil
                repo.transaction do
                  id = repo.create_#{opts.singlename}(res)
                  log_status(:#{opts.table}, id, 'CREATED')
                  log_transaction
                end
                instance = #{opts.singlename}(id)
                success_response("Created #{opts.classnames[:text_name].downcase} \#{instance.#{opts.label_field}}",
                                 instance)
              rescue Sequel::UniqueConstraintViolation
                validation_failed_response(OpenStruct.new(messages: { #{opts.label_field}: ['This #{opts.classnames[:text_name].downcase} already exists'] }))
              rescue Crossbeams::InfoError => e
                failed_response(e.message)
              end

              def update_#{opts.singlename}(id, params)
                res = validate_#{opts.singlename}_params(params)
                return validation_failed_response(res) if res.failure?

                repo.transaction do
                  repo.update_#{opts.singlename}(id, res)
                  log_transaction
                end
                instance = #{opts.singlename}(id)
                success_response("Updated #{opts.classnames[:text_name].downcase} \#{instance.#{opts.label_field}}",
                                 instance)
              rescue Crossbeams::InfoError => e
                failed_response(e.message)
              end

              def delete_#{opts.singlename}(id)
                name = #{opts.singlename}(id).#{opts.label_field}
                repo.transaction do
                  repo.delete_#{opts.singlename}(id)
                  log_status(:#{opts.table}, id, 'DELETED')
                  log_transaction
                end
                success_response("Deleted #{opts.classnames[:text_name].downcase} \#{name}")
              rescue Crossbeams::InfoError => e
                failed_response(e.message)
              rescue Sequel::ForeignKeyConstraintViolation => e
                puts e.message
                failed_response("Unable to delete #{opts.classnames[:text_name].downcase}. It is still referenced\#{e.message.partition('referenced').last}")
              end

              # def complete_a_#{opts.singlename}(id, params)
              #   res = complete_a_record(:#{opts.table}, id, params.merge(enqueue_job: false))
              #   if res.success
              #     success_response(res.message, #{opts.singlename}(id))
              #   else
              #     failed_response(res.message, #{opts.singlename}(id))
              #   end
              # end

              # def reopen_a_#{opts.singlename}(id, params)
              #   res = reopen_a_record(:#{opts.table}, id, params.merge(enqueue_job: false))
              #   if res.success
              #     success_response(res.message, #{opts.singlename}(id))
              #   else
              #     failed_response(res.message, #{opts.singlename}(id))
              #   end
              # end

              # def approve_or_reject_a_#{opts.singlename}(id, params)
              #   res = if params[:approve_action] == 'a'
              #           approve_a_record(:#{opts.table}, id, params.merge(enqueue_job: false))
              #         else
              #           reject_a_record(:#{opts.table}, id, params.merge(enqueue_job: false))
              #         end
              #   if res.success
              #     success_response(res.message, #{opts.singlename}(id))
              #   else
              #     failed_response(res.message, #{opts.singlename}(id))
              #   end
              # end

              def assert_permission!(task, id = nil)
                res = TaskPermissionCheck::#{opts.classnames[:class]}.call(task, id)
                raise Crossbeams::TaskNotPermittedError, res.message unless res.success
              end

              private

              def repo
                @repo ||= #{opts.classnames[:repo]}.new
              end

              def #{opts.singlename}(id)
                repo.find_#{opts.singlename}(id)
              end

              def validate_#{opts.singlename}_params(params)
                #{opts.classnames[:schema]}.call(params)
              end
            end
          end
        RUBY
      end

      private

      def needs_id
        opts.nested_route ? 'parent_id, ' : ''
      end

      def add_parent_to_params
        parent_id_name = opts.inflector.foreign_key(opts.inflector.singularize(opts.nested_route)) if opts.nested_route
        opts.nested_route ? "\n      params[:#{parent_id_name}] = parent_id" : ''
      end
    end

    class PermissionMaker < BaseService
      attr_reader :opts
      def initialize(opts)
        @opts = opts
      end

      def call
        <<~RUBY
          # frozen_string_literal: true

          module #{opts.classnames[:module]}
            module TaskPermissionCheck
              class #{opts.classnames[:class]} < BaseService
                attr_reader :task, :entity
                def initialize(task, #{opts.singlename}_id = nil)
                  @task = task
                  @repo = #{opts.classnames[:repo]}.new
                  @id = #{opts.singlename}_id
                  @entity = @id ? @repo.find_#{opts.singlename}(@id) : nil
                end

                CHECKS = {
                  create: :create_check,
                  edit: :edit_check,
                  delete: :delete_check
                  # complete: :complete_check,
                  # approve: :approve_check,
                  # reopen: :reopen_check
                }.freeze

                def call
                  return failed_response '#{opts.text_name} record not found' unless @entity || task == :create

                  check = CHECKS[task]
                  raise ArgumentError, "Task \\"\#{task}\\" is unknown for \#{self.class}" if check.nil?

                  send(check)
                end

                private

                def create_check
                  all_ok
                end

                def edit_check
                  # return failed_response '#{opts.classnames[:class]} has been completed' if completed?

                  all_ok
                end

                def delete_check
                  # return failed_response '#{opts.classnames[:class]} has been completed' if completed?

                  all_ok
                end

                # def complete_check
                #   return failed_response '#{opts.classnames[:class]} has already been completed' if completed?

                #   all_ok
                # end

                # def approve_check
                #   return failed_response '#{opts.classnames[:class]} has not been completed' unless completed?
                #   return failed_response '#{opts.classnames[:class]} has already been approved' if approved?

                #   all_ok
                # end

                # def reopen_check
                #   return failed_response '#{opts.classnames[:class]} has not been approved' unless approved?

                #   all_ok
                # end

                # def completed?
                #   @entity.completed
                # end

                # def approved?
                #   @entity.approved
                # end
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
        alias_active   = opts.has_short_name ? "#{UtilityFunctions.newline_and_spaces(21)}alias: :#{opts.singlename}," : ''
        alias_inactive = opts.has_short_name ? "#{UtilityFunctions.newline_and_spaces(26)}alias: :#{opts.singlename}," : ''
        if @opts.table_meta.active_column_present?
          <<~RUBY
            # frozen_string_literal: true

            module #{opts.classnames[:module]}
              class #{opts.classnames[:repo]} < BaseRepo
                build_for_select :#{opts.table},#{alias_active}
                                 label: :#{opts.label_field},
                                 value: :id,
                                 order_by: :#{opts.label_field}
                build_inactive_select :#{opts.table},#{alias_inactive}
                                      label: :#{opts.label_field},
                                      value: :id,
                                      order_by: :#{opts.label_field}

                crud_calls_for :#{opts.table}, name: :#{opts.singlename}, wrapper: #{opts.classnames[:class]}
              end
            end
          RUBY
        else
          <<~RUBY
            # frozen_string_literal: true

            module #{opts.classnames[:module]}
              class #{opts.classnames[:repo]} < BaseRepo
                build_for_select :#{opts.table},#{alias_active}
                                 label: :#{opts.label_field},
                                 value: :id,
                                 no_active_check: true,
                                 order_by: :#{opts.label_field}

                crud_calls_for :#{opts.table}, name: :#{opts.singlename}, wrapper: #{opts.classnames[:class]}
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

          module #{opts.classnames[:module]}
            class #{opts.classnames[:class]} < Dry::Struct
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
        attr << 'attribute? :active, Types::Bool' if opts.table_meta.active_column_present?
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

          module #{opts.classnames[:module]}
            #{opts.classnames[:schema]} = Dry::Schema.Params do
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
          max = detail[:max_length] && detail[:max_length] < 200 ? "max_size?: #{detail[:max_length]}" : nil
          attr << if col == :id
                    "optional(:#{col}).#{opts.table_meta.column_dry_validation_type(col, max, detail[:allow_null])}"
                  else
                    "required(:#{col}).#{opts.table_meta.column_dry_validation_type(col, max, detail[:allow_null])}"
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
                            icon: 'view-show',
                            title: 'View',
                            popup: true }
        list[:actions] << { url: "/#{opts.applet}/#{opts.program}/#{opts.table}/$:id$/edit",
                            text: 'edit',
                            icon: 'edit',
                            title: 'Edit',
                            popup: true }
        list[:actions] << { url: "/#{opts.applet}/#{opts.program}/#{opts.table}/$:id$",
                            text: 'delete',
                            icon: 'delete',
                            is_delete: true,
                            popup: true }
        list[:actions] << { url: "/#{opts.applet}/#{opts.program}/#{opts.table}/$:id$/complete",
                            text: 'Complete',
                            icon: 'toggle-on',
                            popup: true,
                            hide_if_true: 'completed',
                            auth: {
                              function: make_caption(opts.applet),
                              program: opts.program_text,
                              permission: 'edit'
                            } }
        list[:actions] << { url: "/#{opts.applet}/#{opts.program}/#{opts.table}/$:id$/approve",
                            text: 'Approve/Reject',
                            icon: 'gavel',
                            popup: true,
                            hide_if_false: 'completed',
                            hide_if_true: 'approved',
                            auth: {
                              function: make_caption(opts.applet),
                              program: opts.program_text,
                              permission: 'approve'
                            } }
        list[:actions] << { url: "/#{opts.applet}/#{opts.program}/#{opts.table}/$:id$/reopen",
                            text: 'Re-open for editing',
                            icon: 'toggle-off',
                            popup: true,
                            hide_if_false: 'approved',
                            auth: {
                              function: make_caption(opts.applet),
                              program: opts.program_text,
                              permission: 'edit'
                            } }
        list[:actions] << { separator: true }
        list[:actions] << { url: "/development/statuses/list/#{opts.table}/$:id$",
                            text: 'status',
                            icon: 'information-solid',
                            title: 'Status',
                            popup: true }
        list[:page_controls] = []
        list[:page_controls] << { control_type: :link,
                                  url: "/#{opts.applet}/#{opts.program}/#{opts.table}/new",
                                  text: "New #{opts.classnames[:text_name]}",
                                  style: :button,
                                  behaviour: :popup }
        list.to_yaml
      end

      def make_caption(value)
        opts.inflector.humanize(value.to_s).gsub(/\s\D/, &:upcase)
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
                              icon: 'view-show',
                              title: 'View',
                              popup: true }
        search[:actions] << { url: "/#{opts.applet}/#{opts.program}/#{opts.table}/$:id$/edit",
                              text: 'edit',
                              icon: 'edit',
                              title: 'Edit',
                              popup: true }
        search[:actions] << { url: "/#{opts.applet}/#{opts.program}/#{opts.table}/$:id$",
                              text: 'delete',
                              icon: 'delete',
                              is_delete: true,
                              popup: true }
        search[:page_controls] = []
        search[:page_controls] << { control_type: :link,
                                    url: "/#{opts.applet}/#{opts.program}/#{opts.table}/new",
                                    text: "New #{opts.classnames[:text_name]}",
                                    style: :button,
                                    behaviour: :popup }
        search.to_yaml
      end
    end

    class RouteMaker < BaseService # rubocop:disable Metrics/ClassLength
      attr_reader :opts
      def initialize(opts)
        @opts = opts
      end

      def call
        <<~RUBY
          # frozen_string_literal: true

          class #{opts.classnames[:roda_class]} < Roda
            route '#{opts.program}', '#{opts.applet}' do |r|
              # #{opts.table.upcase.tr('_', ' ')}
              # --------------------------------------------------------------------------
              r.on '#{opts.table}', Integer do |id|
                interactor = #{opts.classnames[:namespaced_interactor]}.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})

                # Check for notfound:
                r.on !interactor.exists?(:#{opts.table}, id) do
                  handle_not_found(r)
                end

                r.on 'edit' do   # EDIT
                  check_auth!('#{opts.program_text}', 'edit')
                  interactor.assert_permission!(:edit, id)
                  show_partial { #{opts.classnames[:view_prefix]}::Edit.call(id) }
                end

                # r.on 'complete' do
                #   r.get do
                #     check_auth!('#{opts.program_text}', 'edit')
                #     interactor.assert_permission!(:complete, id)
                #     show_partial { #{opts.classnames[:view_prefix]}::Complete.call(id) }
                #   end

                #   r.post do
                #     res = interactor.complete_a_#{opts.singlename}(id, params[:#{opts.singlename}])
                #     if res.success
                #       flash[:notice] = res.message
                #       redirect_to_last_grid(r)
                #     else
                #       re_show_form(r, res) { #{opts.classnames[:view_prefix]}::Complete.call(id, params[:#{opts.singlename}], res.errors) }
                #     end
                #   end
                # end

                # r.on 'approve' do
                #   r.get do
                #     check_auth!('#{opts.program_text}', 'approve')
                #     interactor.assert_permission!(:approve, id)
                #     show_partial { #{opts.classnames[:view_prefix]}::Approve.call(id) }
                #   end

                #   r.post do
                #     res = interactor.approve_or_reject_a_#{opts.singlename}(id, params[:#{opts.singlename}])
                #     if res.success
                #       flash[:notice] = res.message
                #       redirect_to_last_grid(r)
                #     else
                #       re_show_form(r, res) { #{opts.classnames[:view_prefix]}::Approve.call(id, params[:#{opts.singlename}], res.errors) }
                #     end
                #   end
                # end

                # r.on 'reopen' do
                #   r.get do
                #     check_auth!('#{opts.program_text}', 'edit')
                #     interactor.assert_permission!(:reopen, id)
                #     show_partial { #{opts.classnames[:view_prefix]}::Reopen.call(id) }
                #   end

                #   r.post do
                #     res = interactor.reopen_a_#{opts.singlename}(id, params[:#{opts.singlename}])
                #     if res.success
                #       flash[:notice] = res.message
                #       redirect_to_last_grid(r)
                #     else
                #       re_show_form(r, res) { #{opts.classnames[:view_prefix]}::Reopen.call(id, params[:#{opts.singlename}], res.errors) }
                #     end
                #   end
                # end

                r.is do
                  r.get do       # SHOW
                    check_auth!('#{opts.program_text}', 'read')
                    show_partial { #{opts.classnames[:view_prefix]}::Show.call(id) }
                  end
                  r.patch do     # UPDATE
                    res = interactor.update_#{opts.singlename}(id, params[:#{opts.singlename}])
                    if res.success
                      #{update_grid_row.gsub("\n", "\n            ").sub(/            \Z/, '').sub(/\n\Z/, '')}
                    else
                      re_show_form(r, res) { #{opts.classnames[:view_prefix]}::Edit.call(id, form_values: params[:#{opts.singlename}], form_errors: res.errors) }
                    end
                  end
                  r.delete do    # DELETE
                    check_auth!('#{opts.program_text}', 'delete')
                    interactor.assert_permission!(:delete, id)
                    res = interactor.delete_#{opts.singlename}(id)
                    if res.success
                      delete_grid_row(id, notice: res.message)
                    else
                      show_json_error(res.message, status: 200)
                    end
                  end
                end
              end

              #{new_create_routes.chomp.gsub("\n", "\n    ")}
            end
          end
        RUBY
      end

      def new_create_routes
        if opts.nested_route
          nested_new_routes
        else
          plain_new_routes
        end
      end

      def plain_new_routes
        <<~RUBY
          r.on '#{opts.table}' do
            interactor = #{opts.classnames[:namespaced_interactor]}.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})
            r.on 'new' do    # NEW
              check_auth!('#{opts.program_text}', 'new')#{on_new_lastgrid.chomp}
              show_partial_or_page(r) { #{opts.classnames[:view_prefix]}::New.call(remote: fetch?(r)) }
            end
            r.post do        # CREATE
              res = interactor.create_#{opts.singlename}(params[:#{opts.singlename}])
              if res.success
                #{create_success.chomp.gsub("\n", "\n      ")}
              else
                re_show_form(r, res, url: '/#{opts.applet}/#{opts.program}/#{opts.table}/new') do
                  #{opts.classnames[:view_prefix]}::New.call(form_values: params[:#{opts.singlename}],
                  #{UtilityFunctions.spaces_from_string_lengths(11, opts.classnames[:view_prefix])}form_errors: res.errors,
                  #{UtilityFunctions.spaces_from_string_lengths(11, opts.classnames[:view_prefix])}remote: fetch?(r))
                end
              end
            end
          end
        RUBY
      end

      def nested_new_routes
        <<~RUBY
          r.on '#{opts.nested_route}', Integer do |id|
            r.on '#{opts.table}' do
              interactor = #{opts.classnames[:namespaced_interactor]}.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})
              r.on 'new' do    # NEW
                check_auth!('#{opts.program_text}', 'new')#{on_new_lastgrid.chomp}
                show_partial_or_page(r) { #{opts.classnames[:view_prefix]}::New.call(id, remote: fetch?(r)) }
              end
              r.post do        # CREATE
                res = interactor.create_#{opts.singlename}(id, params[:#{opts.singlename}])
                if res.success
                  #{create_success.chomp.gsub("\n", "\n      ")}
                else
                  re_show_form(r, res, url: "/#{opts.applet}/#{opts.program}/#{opts.nested_route}/\#{id}/#{opts.table}/new") do
                    #{opts.classnames[:view_prefix]}::New.call(id,
                    #{UtilityFunctions.spaces_from_string_lengths(11, opts.classnames[:view_prefix])}form_values: params[:#{opts.singlename}],
                    #{UtilityFunctions.spaces_from_string_lengths(11, opts.classnames[:view_prefix])}form_errors: res.errors,
                    #{UtilityFunctions.spaces_from_string_lengths(11, opts.classnames[:view_prefix])}remote: fetch?(r))
                  end
                end
              end
            end
          end
        RUBY
      end

      def update_grid_row
        if opts.table_meta.columns_without(%i[id created_at updated_at active]).length > 3
          update_grid_row_many
        else
          update_grid_row_few
        end
      end

      def update_grid_row_many
        row_keys = opts.table_meta.columns_without(%i[id created_at updated_at active]).map(&:to_s).join("\n  ")
        <<~RUBY
          row_keys = %i[
            #{row_keys}
          ]
          update_grid_row(id, changes: select_attributes(res.instance, row_keys), notice: res.message)
        RUBY
      end

      def update_grid_row_few
        <<~RUBY
          update_grid_row(id, changes: { #{grid_refresh_fields} },
                              notice: res.message)
        RUBY
      end

      def grid_refresh_fields
        opts.table_meta.columns_without(%i[id created_at updated_at active]).map do |col|
          "#{col}: res.instance[:#{col}]"
        end.join(', ')
      end

      def on_new_lastgrid
        return '' unless opts.new_from_menu

        "\n    set_last_grid_url('/list/#{opts.table}', r)"
      end

      def create_success
        if opts.new_from_menu
          row_keys = opts.table_meta.columns_without(%i[created_at updated_at]).map(&:to_s).join("\n    ")
          <<~RUBY
            if fetch?(r)
              row_keys = %i[
                #{row_keys}
              ]
              add_grid_row(attrs: select_attributes(res.instance, row_keys),
                           notice: res.message)
            else
              flash[:notice] = res.message
              redirect_to_last_grid(r)
            end
          RUBY
        else
          row_keys = opts.table_meta.columns_without(%i[created_at updated_at]).map(&:to_s).join("\n  ")
          <<~RUBY
            row_keys = %i[
              #{row_keys}
            ]
            add_grid_row(attrs: select_attributes(res.instance, row_keys),
                         notice: res.message)
          RUBY
        end
      end
    end

    class UiRuleMaker < BaseService # rubocop:disable Metrics/ClassLength
      attr_reader :opts
      def initialize(opts)
        @opts = opts
      end

      def call
        <<~RUBY
          # frozen_string_literal: true

          module UiRules
            class #{opts.classnames[:class]}Rule < Base
              def generate_rules
                @repo = #{opts.classnames[:namespaced_repo]}.new
                make_form_object
                apply_form_values

                common_values_for_fields common_fields

                set_show_fields if %i[show reopen].include? @mode
                # set_complete_fields if @mode == :complete
                # set_approve_fields if @mode == :approve

                # add_approve_behaviours if @mode == :approve

                form_name '#{opts.singlename}'
              end

              def set_show_fields
                #{show_fields.join(UtilityFunctions.newline_and_spaces(6))}
              end

              # def set_approve_fields
              #   set_show_fields
              #   fields[:approve_action] = { renderer: :select, options: [%w[Approve a], %w[Reject r]], required: true }
              #   fields[:reject_reason] = { renderer: :textarea, disabled: true }
              # end

              # def set_complete_fields
              #   set_show_fields
              #   user_repo = DevelopmentApp::UserRepo.new
              #   fields[:to] = { renderer: :select, options: user_repo.email_addresses(user_email_group: AppConst::EMAIL_GROUP_#{opts.singlename.upcase}_APPROVERS), caption: 'Email address of person to notify', required: true }
              # end

              def common_fields
                {
                  #{common_fields.join(UtilityFunctions.comma_newline_and_spaces(8))}
                }
              end

              def make_form_object
                if @mode == :new
                  make_new_form_object
                  return
                end

                @form_object = @repo.find_#{opts.singlename}(@options[:id])
              end

              def make_new_form_object
                @form_object = OpenStruct.new(#{struct_fields.join(UtilityFunctions.comma_newline_and_spaces(36))})
              end

              # private

              # def add_approve_behaviours
              #   behaviours do |behaviour|
              #     behaviour.enable :reject_reason, when: :approve_action, changes_to: ['r']
              #   end
              # end
            end
          end
        RUBY
      end

      private

      def make_caption(value)
        opts.inflector.humanize(value.to_s).gsub(/\s\D/, &:upcase)
      end

      def fields_to_use(for_show = false)
        cols = if for_show
                 %i[id created_at updated_at]
               else
                 %i[id created_at updated_at active]
               end
        opts.table_meta.columns_without(cols)
      end

      def show_fields
        flds = []
        fields_to_use(true).each do |f|
          fk = opts.table_meta.fk_lookup[f]
          next unless fk

          tm = TableMeta.new(fk[:table])
          singlename = opts.inflector.singularize(fk[:table].to_s)
          klassname = opts.inflector.camelize(singlename)
          fk_repo = "#{opts.classnames[:module]}::#{klassname}Repo"
          code = tm.likely_label_field
          flds << "# #{f}_label = #{fk_repo}.new.find_#{singlename}(@form_object.#{f})&.#{code}"
          flds << "#{f}_label = @repo.find(:#{fk[:table]}, #{opts.classnames[:module]}::#{klassname}, @form_object.#{f})&.#{code}"
        end

        flds + fields_to_use(true).map do |f|
          fk = opts.table_meta.fk_lookup[f]
          if fk.nil?
            this_col = opts.table_meta.col_lookup[f]
            if this_col[:type] == :boolean
              "fields[:#{f}] = { renderer: :label, as_boolean: true }"
            elsif this_col[:type] == :datetime
              "fields[:#{f}] = { renderer: :label, format: :without_timezone_or_seconds }"
            else
              "fields[:#{f}] = { renderer: :label }"
            end
          else
            "fields[:#{f}] = { renderer: :label, with_value: #{f}_label, caption: '#{make_caption(f.to_s.chomp('_id'))}' }"
          end
        end
      end

      # bool == checkbox, fk == select etc
      def common_fields
        fields_to_use.map do |field|
          this_col = opts.table_meta.col_lookup[field]
          required = this_col[:allow_null] ? '' : ' required: true '
          if this_col.nil?
            "#{field}: {}"
          elsif this_col[:type] == :boolean # int: number, _id: select.
            "#{field}: { renderer: :checkbox }"
          elsif field.to_s.end_with?('_id')
            make_select(field, this_col[:allow_null])
          else
            "#{field}: {#{required}}"
          end
        end
      end

      def make_select(field, can_be_null)
        fk = opts.table_meta.fk_lookup[field]
        return "#{field}: {}" if fk.nil?

        singlename  = opts.inflector.singularize(fk[:table].to_s)
        klassname   = opts.inflector.camelize(singlename)
        fk_repo = "#{opts.classnames[:module]}::#{klassname}Repo"
        # get fk data & make select - or (if no fk....)
        tm = TableMeta.new(fk[:table])
        required = can_be_null ? '' : ', required: true'
        if tm.active_column_present?
          "#{field}: { renderer: :select, options: #{fk_repo}.new.for_select_#{fk[:table]}, disabled_options: #{fk_repo}.new.for_select_inactive_#{fk[:table]}, caption: '#{make_caption(field.to_s.chomp('_id'))}'#{required} }"
        else
          "#{field}: { renderer: :select, options: #{fk_repo}.new.for_select_#{fk[:table]}, caption: '#{make_caption(field.to_s.chomp('_id'))}'#{required} }"
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

    class TestMaker < BaseService # rubocop:disable Metrics/ClassLength
      attr_reader :opts
      def initialize(opts)
        @opts = opts
      end

      def call
        {
          interactor: test_interactor,
          factory: test_factory,
          permission: test_permission,
          repo: test_repo,
          route: test_route
        }
      end

      private

      def columnise(with_fk: true)
        attr = []
        opts.table_meta.columns_without(%i[created_at updated_at active]).each do |col|
          attr << "#{col}: #{opts.table_meta.column_dummy_data(col, with_fk: with_fk)}"
        end
        attr << 'active: true' if opts.table_meta.active_column_present?
        attr
      end

      def test_repo
        <<~RUBY
          # frozen_string_literal: true

          require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

          module #{opts.classnames[:module]}
            class Test#{opts.classnames[:repo]} < MiniTestWithHooks
              def test_for_selects
                assert_respond_to repo, :for_select_#{opts.has_short_name ? opts.singlename : opts.table}
              end

              def test_crud_calls
                test_crud_calls_for :#{opts.table}, name: :#{opts.singlename}, wrapper: #{opts.classnames[:class]}
              end

              private

              def repo
                #{opts.classnames[:repo]}.new
              end
            end
          end
        RUBY
      end

      def test_interactor
        ent = columnise.join(",\n        ")
        req_col = opts.table_meta.likely_label_field || '???'
        <<~RUBY
          # frozen_string_literal: true

          require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

          module #{opts.classnames[:module]}
            class Test#{opts.classnames[:interactor]} < MiniTestWithHooks
              include #{opts.classnames[:factory]}

              def test_repo
                repo = interactor.send(:repo)
                assert repo.is_a?(#{opts.classnames[:namespaced_repo]})
              end

              def test_#{opts.singlename}
                #{opts.classnames[:namespaced_repo]}.any_instance.stubs(:find_#{opts.singlename}).returns(fake_#{opts.singlename})
                entity = interactor.send(:#{opts.singlename}, 1)
                assert entity.is_a?(#{opts.classnames[:class]})
              end

              def test_create_#{opts.singlename}
                attrs = fake_#{opts.singlename}.to_h.reject { |k, _| k == :id }
                res = interactor.create_#{opts.singlename}(attrs)
                assert res.success, "\#{res.message} : \#{res.errors.inspect}"
                assert_instance_of(#{opts.classnames[:class]}, res.instance)
                assert res.instance.id.nonzero?
              end

              def test_create_#{opts.singlename}_fail
                attrs = fake_#{opts.singlename}(#{req_col}: nil).to_h.reject { |k, _| k == :id }
                res = interactor.create_#{opts.singlename}(attrs)
                refute res.success, 'should fail validation'
                assert_equal ['must be filled'], res.errors[:#{req_col}]
              end

              def test_update_#{opts.singlename}
                id = create_#{opts.singlename}
                attrs = interactor.send(:repo).find_hash(:#{opts.table}, id).reject { |k, _| k == :id }
                value = attrs[:#{req_col}]
                attrs[:#{req_col}] = 'a_change'
                res = interactor.update_#{opts.singlename}(id, attrs)
                assert res.success, "\#{res.message} : \#{res.errors.inspect}"
                assert_instance_of(#{opts.classnames[:class]}, res.instance)
                assert_equal 'a_change', res.instance.#{req_col}
                refute_equal value, res.instance.#{req_col}
              end

              def test_update_#{opts.singlename}_fail
                id = create_#{opts.singlename}
                attrs = interactor.send(:repo).find_hash(:#{opts.table}, id).reject { |k, _| %i[id #{req_col}].include?(k) }
                res = interactor.update_#{opts.singlename}(id, attrs)
                refute res.success, "\#{res.message} : \#{res.errors.inspect}"
                assert_equal ['is missing'], res.errors[:#{req_col}]
              end

              def test_delete_#{opts.singlename}
                id = create_#{opts.singlename}
                assert_count_changed(:#{opts.table}, -1) do
                  res = interactor.delete_#{opts.singlename}(id)
                  assert res.success, res.message
                end
              end

              private

              def #{opts.singlename}_attrs
                #{foreign_ids}{
                  #{ent}
                }
              end

              def fake_#{opts.singlename}(overrides = {})
                #{opts.classnames[:class]}.new(#{opts.singlename}_attrs.merge(overrides))
              end

              def interactor
                @interactor ||= #{opts.classnames[:interactor]}.new(current_user, {}, {}, {})
              end
            end
          end
        RUBY
      end

      def foreign_ids
        lkps = []
        opts.table_meta.column_names.each do |col|
          lkps << "#{opts.inflector.singularize(opts.table_meta.fk_lookup[col][:table])}_id = create_#{opts.inflector.singularize(opts.table_meta.fk_lookup[col][:table])}" if opts.table_meta.fk_lookup[col]
        end
        show_lkp(lkps)
      end

      def test_factory
        dependency_tree = opts.table_meta.dependency_tree
        code_chunks = make_code_chunks(dependency_tree)
        <<~RUBY
          # frozen_string_literal: true

          # ========================================================= #
          # NB. Scaffolds for test factories should be combined       #
          #     - Otherwise you'll have methods for the same table in #
          #       several factories.                                  #
          #     - Rather create a factory for several related tables  #
          # ========================================================= #

          module #{opts.classnames[:module]}
            module #{opts.classnames[:factory]}
              #{code_chunks.join("\n    ")}
            end
          end
        RUBY
      end

      def make_code_chunks(dependency_tree)
        out = []
        dependency_tree.each do |table, fields|
          lkps = []
          fields.each do |field|
            lkps << "#{opts.inflector.singularize(field[:ftbl])}_id = create_#{opts.inflector.singularize(field[:ftbl])}" if field[:ftbl]
          end
          s = <<~RUBY
            def create_#{opts.inflector.singularize(table)}(opts = {})
                  #{show_lkp(lkps)}default = {
                    #{fields.map { |f| render_field(f, table) }.join(",\n        ")}
                  }
                  DB[:#{table}].insert(default.merge(opts))
                end
          RUBY
          out << s
        end
        out[-1] = out.last.chomp
        out
      end

      def show_lkp(lkps)
        return '' if lkps.empty?

        "#{lkps.join("\n      ")}\n\n      "
      end

      def render_field(field, table)
        if field[:ftbl]
          "#{field[:name]}: #{opts.inflector.singularize(field[:ftbl])}_id"
        elsif field[:name] == :active
          "#{field[:name]}: true"
        else
          tab = TableMeta.new(table)
          "#{field[:name]}: #{tab.column_dummy_data(field[:name], faker: true, type: field[:type])}"
        end
      end

      def test_permission
        perm_check = "#{opts.classnames[:module]}::TaskPermissionCheck::#{opts.classnames[:class]}"
        ent = columnise(with_fk: false).join(",\n        ")
        <<~RUBY
          # frozen_string_literal: true

          require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

          module #{opts.classnames[:module]}
            class Test#{opts.classnames[:class]}Permission < Minitest::Test
              include Crossbeams::Responses
              include #{opts.classnames[:factory]}

              def entity(attrs = {})
                base_attrs = {
                  #{ent}
                }
                #{opts.classnames[:module]}::#{opts.classnames[:class]}.new(base_attrs.merge(attrs))
              end

              def test_create
                res = #{perm_check}.call(:create)
                assert res.success, 'Should always be able to create a #{opts.singlename}'
              end

              def test_edit
                #{opts.classnames[:module]}::#{opts.classnames[:repo]}.any_instance.stubs(:find_#{opts.singlename}).returns(entity)
                res = #{perm_check}.call(:edit, 1)
                assert res.success, 'Should be able to edit a #{opts.singlename}'

                # #{opts.classnames[:module]}::#{opts.classnames[:repo]}.any_instance.stubs(:find_#{opts.singlename}).returns(entity(completed: true))
                # res = #{perm_check}.call(:edit, 1)
                # refute res.success, 'Should not be able to edit a completed #{opts.singlename}'
              end

              def test_delete
                #{opts.classnames[:module]}::#{opts.classnames[:repo]}.any_instance.stubs(:find_#{opts.singlename}).returns(entity)
                res = #{perm_check}.call(:delete, 1)
                assert res.success, 'Should be able to delete a #{opts.singlename}'

                # #{opts.classnames[:module]}::#{opts.classnames[:repo]}.any_instance.stubs(:find_#{opts.singlename}).returns(entity(completed: true))
                # res = #{perm_check}.call(:delete, 1)
                # refute res.success, 'Should not be able to delete a completed #{opts.singlename}'
              end

              # def test_complete
              #   #{opts.classnames[:module]}::#{opts.classnames[:repo]}.any_instance.stubs(:find_#{opts.singlename}).returns(entity)
              #   res = #{perm_check}.call(:complete, 1)
              #   assert res.success, 'Should be able to complete a #{opts.singlename}'

              #   #{opts.classnames[:module]}::#{opts.classnames[:repo]}.any_instance.stubs(:find_#{opts.singlename}).returns(entity(completed: true))
              #   res = #{perm_check}.call(:complete, 1)
              #   refute res.success, 'Should not be able to complete an already completed #{opts.singlename}'
              # end

              # def test_approve
              #   #{opts.classnames[:module]}::#{opts.classnames[:repo]}.any_instance.stubs(:find_#{opts.singlename}).returns(entity(completed: true, approved: false))
              #   res = #{perm_check}.call(:approve, 1)
              #   assert res.success, 'Should be able to approve a completed #{opts.singlename}'

              #   #{opts.classnames[:module]}::#{opts.classnames[:repo]}.any_instance.stubs(:find_#{opts.singlename}).returns(entity)
              #   res = #{perm_check}.call(:approve, 1)
              #   refute res.success, 'Should not be able to approve a non-completed #{opts.singlename}'

              #   #{opts.classnames[:module]}::#{opts.classnames[:repo]}.any_instance.stubs(:find_#{opts.singlename}).returns(entity(completed: true, approved: true))
              #   res = #{perm_check}.call(:approve, 1)
              #   refute res.success, 'Should not be able to approve an already approved #{opts.singlename}'
              # end

              # def test_reopen
              #   #{opts.classnames[:module]}::#{opts.classnames[:repo]}.any_instance.stubs(:find_#{opts.singlename}).returns(entity)
              #   res = #{perm_check}.call(:reopen, 1)
              #   refute res.success, 'Should not be able to reopen a #{opts.singlename} that has not been approved'

              #   #{opts.classnames[:module]}::#{opts.classnames[:repo]}.any_instance.stubs(:find_#{opts.singlename}).returns(entity(completed: true, approved: true))
              #   res = #{perm_check}.call(:reopen, 1)
              #   assert res.success, 'Should be able to reopen an approved #{opts.singlename}'
              # end
            end
          end
        RUBY
      end

      def test_route
        base_route = "#{opts.applet}/#{opts.program}/"
        <<~RUBY
          # frozen_string_literal: true

          require File.join(File.expand_path('./../../../', __dir__), 'test_helper_for_routes')

          class Test#{opts.classnames[:class]}Routes < RouteTester

            INTERACTOR = #{opts.classnames[:namespaced_interactor]}

            def test_edit
              authorise_pass! permission_check: #{opts.classnames[:module]}::TaskPermissionCheck::#{opts.classnames[:class]}
              ensure_exists!(INTERACTOR)
              #{opts.classnames[:view_prefix]}::Edit.stub(:call, bland_page) do
                get '#{base_route}#{opts.table}/1/edit', {}, 'rack.session' => { user_id: 1 }
              end
              expect_bland_page
            end

            def test_edit_fail
              authorise_fail!
              ensure_exists!(INTERACTOR)
              get '#{base_route}#{opts.table}/1/edit', {}, 'rack.session' => { user_id: 1 }
              expect_permission_error
            end

            def test_show
              authorise_pass!
              ensure_exists!(INTERACTOR)
              #{opts.classnames[:view_prefix]}::Show.stub(:call, bland_page) do
                get '#{base_route}#{opts.table}/1', {}, 'rack.session' => { user_id: 1 }
              end
              expect_bland_page
            end

            def test_show_fail
              authorise_fail!
              ensure_exists!(INTERACTOR)
              get '#{base_route}#{opts.table}/1', {}, 'rack.session' => { user_id: 1 }
              expect_permission_error
            end

            def test_update
              authorise_pass!
              ensure_exists!(INTERACTOR)
              row_vals = Hash.new(1)
              INTERACTOR.any_instance.stubs(:update_#{opts.singlename}).returns(ok_response(instance: row_vals))
              patch_as_fetch '#{base_route}#{opts.table}/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
              expect_json_update_grid
            end

            def test_update_fail
              authorise_pass!
              ensure_exists!(INTERACTOR)
              INTERACTOR.any_instance.stubs(:update_#{opts.singlename}).returns(bad_response)
              #{opts.classnames[:view_prefix]}::Edit.stub(:call, bland_page) do
                patch_as_fetch '#{base_route}#{opts.table}/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
              end
              expect_json_replace_dialog(has_error: true)
            end

            def test_delete
              authorise_pass! permission_check: #{opts.classnames[:module]}::TaskPermissionCheck::#{opts.classnames[:class]}
              ensure_exists!(INTERACTOR)
              INTERACTOR.any_instance.stubs(:delete_#{opts.singlename}).returns(ok_response)
              delete_as_fetch '#{base_route}#{opts.table}/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
              expect_json_delete_from_grid
            end

            def test_delete_fail
              authorise_pass! permission_check: #{opts.classnames[:module]}::TaskPermissionCheck::#{opts.classnames[:class]}
              ensure_exists!(INTERACTOR)
              INTERACTOR.any_instance.stubs(:delete_#{opts.singlename}).returns(bad_response)
              delete_as_fetch '#{base_route}#{opts.table}/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
              expect_json_error
            end

            def test_new
              authorise_pass!
              ensure_exists!(INTERACTOR)
              #{opts.classnames[:view_prefix]}::New.stub(:call, bland_page) do
                get  '#{base_route}#{opts.table}/new', {}, 'rack.session' => { user_id: 1 }
              end
              expect_bland_page
            end

            def test_new_fail
              authorise_fail!
              ensure_exists!(INTERACTOR)
              get '#{base_route}#{opts.table}/new', {}, 'rack.session' => { user_id: 1 }
              expect_permission_error
            end

            def test_create_remotely
              authorise_pass!
              ensure_exists!(INTERACTOR)
              row_vals = Hash.new(1)
              INTERACTOR.any_instance.stubs(:create_#{opts.singlename}).returns(ok_response(instance: row_vals))
              post_as_fetch '#{base_route}#{opts.table}', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
              expect_json_add_to_grid(has_notice: true)
            end

            def test_create_remotely_fail
              authorise_pass!
              ensure_exists!(INTERACTOR)
              INTERACTOR.any_instance.stubs(:create_#{opts.singlename}).returns(bad_response)
              #{opts.classnames[:view_prefix]}::New.stub(:call, bland_page) do
                post_as_fetch '#{base_route}#{opts.table}', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
              end
              expect_json_replace_dialog
            end#{non_fetch_new(base_route).chomp.gsub("\n", "\n  ")}
          end
        RUBY
      end

      def non_fetch_new(base_route)
        return '' unless opts.new_from_menu

        <<~RUBY


          def test_create
            authorise_pass!
            ensure_exists!(INTERACTOR)
            INTERACTOR.any_instance.stubs(:create_#{opts.singlename}).returns(ok_response)
            post '#{base_route}#{opts.table}', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
            expect_ok_redirect
          end

          def test_create_fail
            authorise_pass!
            ensure_exists!(INTERACTOR)
            INTERACTOR.any_instance.stubs(:create_#{opts.singlename}).returns(bad_response)
            #{opts.classnames[:view_prefix]}::New.stub(:call, bland_page) do
              post_as_fetch '#{base_route}#{opts.table}', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
            end
            expect_bad_page

            #{opts.classnames[:view_prefix]}::New.stub(:call, bland_page) do
              post '#{base_route}#{opts.table}', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
            end
            expect_bad_redirect(url: '/#{base_route}#{opts.table}/new')
          end
        RUBY
      end
    end

    class ViewMaker < BaseService # rubocop:disable Metrics/ClassLength
      attr_reader :opts
      def initialize(opts)
        @opts = opts
      end

      def call
        {
          new: new_view,
          edit: edit_view,
          show: show_view,
          complete: complete_view,
          approve: approve_view,
          reopen: reopen_view
        }
      end

      private

      def fields_to_use(for_show = false)
        cols = if for_show
                 %i[id created_at updated_at]
               else
                 %i[id created_at updated_at active]
               end
        opts.table_meta.columns_without(cols)
      end

      def form_fields(for_show = false)
        fields_to_use(for_show).map { |f| "form.add_field :#{f}" }.join(UtilityFunctions.newline_and_spaces(14))
      end

      def needs_id
        opts.nested_route ? 'parent_id, ' : ''
      end

      def new_form_url
        if opts.nested_route
          "\"/#{opts.applet}/#{opts.program}/#{opts.nested_route}/\#{parent_id}/#{opts.table}\""
        else
          "'/#{opts.applet}/#{opts.program}/#{opts.table}'"
        end
      end

      def new_view
        <<~RUBY
          # frozen_string_literal: true

          module #{opts.classnames[:applet]}
            module #{opts.classnames[:program]}
              module #{opts.classnames[:class]}
                class New
                  def self.call(#{needs_id}form_values: nil, form_errors: nil, remote: true)
                    ui_rule = UiRules::Compiler.new(:#{opts.singlename}, :new, form_values: form_values)
                    rules   = ui_rule.compile

                    layout = Crossbeams::Layout::Page.build(rules) do |page|
                      page.form_object ui_rule.form_object
                      page.form_values form_values
                      page.form_errors form_errors
                      page.form do |form|
                        form.caption 'New #{opts.text_name}'
                        form.action #{new_form_url}
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
        <<~RUBY
          # frozen_string_literal: true

          module #{opts.classnames[:applet]}
            module #{opts.classnames[:program]}
              module #{opts.classnames[:class]}
                class Edit
                  def self.call(id, form_values: nil, form_errors: nil)
                    ui_rule = UiRules::Compiler.new(:#{opts.singlename}, :edit, id: id, form_values: form_values)
                    rules   = ui_rule.compile

                    layout = Crossbeams::Layout::Page.build(rules) do |page|
                      page.form_object ui_rule.form_object
                      page.form_values form_values
                      page.form_errors form_errors
                      page.form do |form|
                        form.caption 'Edit #{opts.text_name}'
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
        <<~RUBY
          # frozen_string_literal: true

          module #{opts.classnames[:applet]}
            module #{opts.classnames[:program]}
              module #{opts.classnames[:class]}
                class Show
                  def self.call(id)
                    ui_rule = UiRules::Compiler.new(:#{opts.singlename}, :show, id: id)
                    rules   = ui_rule.compile

                    layout = Crossbeams::Layout::Page.build(rules) do |page|
                      page.form_object ui_rule.form_object
                      page.form do |form|
                        # form.caption '#{opts.text_name}'
                        form.view_only!
                        #{form_fields(true)}
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

      def complete_view
        <<~RUBY
          # frozen_string_literal: true

          module #{opts.classnames[:applet]}
            module #{opts.classnames[:program]}
              module #{opts.classnames[:class]}
                class Complete
                  def self.call(id)
                    ui_rule = UiRules::Compiler.new(:#{opts.singlename}, :complete, id: id)
                    rules   = ui_rule.compile

                    layout = Crossbeams::Layout::Page.build(rules) do |page|
                      page.form_object ui_rule.form_object
                      page.form do |form|
                        form.caption 'Complete #{opts.text_name}'
                        form.action "/#{opts.applet}/#{opts.program}/#{opts.table}/\#{id}/complete"
                        form.remote!
                        form.submit_captions 'Complete'
                        form.add_text 'Are you sure you want to complete this #{opts.singlename}?', wrapper: :h3
                        form.add_field :to
                        #{form_fields(true)}
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

      def approve_view
        <<~RUBY
          # frozen_string_literal: true

          module #{opts.classnames[:applet]}
            module #{opts.classnames[:program]}
              module #{opts.classnames[:class]}
                class Approve
                  def self.call(id)
                    ui_rule = UiRules::Compiler.new(:#{opts.singlename}, :approve, id: id)
                    rules   = ui_rule.compile

                    layout = Crossbeams::Layout::Page.build(rules) do |page|
                      page.form_object ui_rule.form_object
                      page.form do |form|
                        form.caption 'Approve or Reject #{opts.text_name}'
                        form.action "/#{opts.applet}/#{opts.program}/#{opts.table}/\#{id}/approve"
                        form.remote!
                        form.submit_captions 'Approve or Reject'
                        form.add_field :approve_action
                        #{form_fields(true)}
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

      def reopen_view
        <<~RUBY
          # frozen_string_literal: true

          module #{opts.classnames[:applet]}
            module #{opts.classnames[:program]}
              module #{opts.classnames[:class]}
                class Reopen
                  def self.call(id)
                    ui_rule = UiRules::Compiler.new(:#{opts.singlename}, :reopen, id: id)
                    rules   = ui_rule.compile

                    layout = Crossbeams::Layout::Page.build(rules) do |page|
                      page.form_object ui_rule.form_object
                      page.form do |form|
                        form.caption 'Reopen #{opts.text_name}'
                        form.action "/#{opts.applet}/#{opts.program}/#{opts.table}/\#{id}/reopen"
                        form.remote!
                        form.submit_captions 'Reopen'
                        form.add_text 'Are you sure you want to reopen this #{opts.singlename} for editing?', wrapper: :h3
                        #{form_fields(true)}
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
      attr_reader :opts, :base_sql
      def initialize(opts)
        @opts = opts
        @base_sql = nil
        @repo = DevelopmentApp::DevelopmentRepo.new
      end

      def call
        @base_sql = <<~SQL
          SELECT #{columns}, fn_current_status('#{opts.table}', #{opts.table}.id) AS status
          FROM #{opts.table}
          #{make_joins}
        SQL
        report = Crossbeams::Dataminer::Report.new(opts.table.split('_').map(&:capitalize).join(' '))
        report.sql = @base_sql
        report
      end

      private

      def columns # rubocop:disable Metrics/PerceivedComplexity
        tab_cols = opts.table_meta.column_names.map { |col| "#{opts.table}.#{col}" }
        fk_cols  = []
        used_tables = Hash.new(0)
        opts.table_meta.foreigns.each do |fk|
          if fk[:table] == :party_roles # Special treatment for party_role lookups to get party name
            fk[:columns].each do |fk_col|
              fk_cols << "fn_party_role_name(#{opts.table}.#{fk_col}) AS #{fk_col.to_s.sub(/_id$/, '')}"
            end
          else
            tab_alias = fk[:table]
            cnt       = used_tables[fk[:table]] += 1
            tab_alias = "#{tab_alias}#{cnt}" if cnt > 1
            fk_col = get_representative_col_from_table(fk[:table])
            pre = if fk[:table].to_s.start_with?(fk[:columns].first.to_s.sub(/_id$/, ''))
                    ''
                  else
                    "#{fk[:columns].first.to_s.sub(/_id$/, '')}_"
                  end

            fk_cols << if opts.table_meta.column_names.include?(fk_col.to_sym)
                         "#{tab_alias}.#{fk_col} AS #{fk[:table]}_#{fk_col}"
                       elsif pre == ''
                         "#{tab_alias}.#{fk_col}"
                       else
                         "#{tab_alias}.#{fk_col} AS #{pre}#{fk_col}"
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
        new_report = DmCreator.new(DB, report).modify_column_datatypes
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

    class ServiceMaker < BaseService
      attr_reader :opts
      def initialize(opts)
        @opts = opts
      end

      def call
        files = []
        opts.classnames[:service_classes].each do |klass|
          files << text(klass)
        end
        files
      end

      private

      def text(klass)
        <<~RUBY
          # frozen_string_literal: true

          module #{opts.classnames[:applet]}App
            class #{klass} < BaseService
              attr_reader :id, :repo

              def initialize(id)
                @id = id
                @repo = #{opts.classnames[:repo]}.new
              end

              def call
                repo.do_work
                success_response('#{klass} was successful')
              end
            end
          end
        RUBY
      end
    end

    class JobMaker < BaseService
      attr_reader :opts
      def initialize(opts)
        @opts = opts
      end

      def call
        files = []
        opts.classnames[:job_classes].each do |klass|
          files << text(klass)
        end
        files
      end

      private

      def text(klass)
        <<~RUBY
          # frozen_string_literal: true

          module #{opts.classnames[:applet]}App
            module Job
              class #{klass} < BaseQueJob
                def run(id)
                  repo = #{opts.classnames[:repo]}.new
                  thing = repo.find_thing(id)

                  repo.transaction do
                    do_work
                    finish
                  end
                end

                private

                def do_work
                  # work..
                end
              end
            end
          end
        RUBY
      end
    end

    class AppletMaker < BaseService
      attr_reader :opts
      def initialize(opts)
        @opts = opts
      end

      def call
        <<~RUBY
          # frozen_string_literal: true

          root_dir = File.expand_path('..', __dir__)
          Dir["\#{root_dir}/#{opts.applet}/entities/*.rb"].sort.each { |f| require f }
          Dir["\#{root_dir}/#{opts.applet}/interactors/*.rb"].sort.each { |f| require f }
          #{job_comment}Dir["\#{root_dir}/#{opts.applet}/jobs/*.rb"].sort.each { |f| require f }
          Dir["\#{root_dir}/#{opts.applet}/repositories/*.rb"].sort.each { |f| require f }
          #{srv_comment}Dir["\#{root_dir}/#{opts.applet}/services/*.rb"].sort.each { |f| require f }
          # Dir["\#{root_dir}/#{opts.applet}/task_permission_checks/*.rb"].sort.each { |f| require f }
          Dir["\#{root_dir}/#{opts.applet}/ui_rules/*.rb"].sort.each { |f| require f }
          Dir["\#{root_dir}/#{opts.applet}/validations/*.rb"].sort.each { |f| require f }
          Dir["\#{root_dir}/#{opts.applet}/views/**/*.rb"].sort.each { |f| require f }

          module #{opts.classnames[:module]}
          end
        RUBY
      end

      def job_comment
        return '# ' if opts.jobs.nil?

        ''
      end

      def srv_comment
        return '# ' if opts.services.nil?

        ''
      end
    end

    class MenuMigrationMaker < BaseService
      attr_reader :opts
      def initialize(opts)
        @opts = opts
      end

      def titleize(str)
        str.split(' ').map(&:capitalize).join(' ')
      end

      def make_caption(value)
        opts.inflector.humanize(value.to_s).gsub(/\s\D/, &:upcase)
      end

      def call
        menu_required = check_for_menu_required
        case menu_required
        when :function
          make_function_menu
        when :program
          make_program_menu
        else
          make_progfunc_menu
        end
      end

      def make_function_menu
        <<~RUBY
          # Save this as something like [db/menu/#{Time.now.strftime('%Y%m%d%H%M')}_#{opts.applet}.rb]

          # Then run [bundle exec rake menu:migrate]

          Crossbeams::MenuMigrations::Migrator.migration('#{opts.classnames[:roda_class]}') do
            up do
              add_functional_area '#{make_caption(opts.applet)}'
              add_program '#{make_caption(opts.program_text)}', functional_area: '#{make_caption(opts.applet)}', seq: 1
              #{opts.new_from_menu ? '' : '# '}add_program_function 'New #{make_caption(opts.singlename)}', functional_area: '#{make_caption(opts.applet)}', program: '#{make_caption(opts.program_text)}', url: '/#{opts.applet}/#{opts.program}/#{opts.table}/new', seq: 1
              add_program_function 'List #{make_caption(opts.table)}', functional_area: '#{make_caption(opts.applet)}', program: '#{make_caption(opts.program_text)}', url: '/list/#{opts.table}', seq: 2
              # add_program_function 'Search #{make_caption(opts.table)}', functional_area: '#{make_caption(opts.applet)}', program: '#{make_caption(opts.program_text)}', url: '/search/#{opts.table}', seq: 3
            end

            down do
              # drop_program_function 'Search #{make_caption(opts.singlename)}', functional_area: '#{make_caption(opts.applet)}', program: '#{make_caption(opts.program_text)}'
              # drop_program_function 'List #{make_caption(opts.singlename)}', functional_area: '#{make_caption(opts.applet)}', program: '#{make_caption(opts.program_text)}'
              # drop_program_function 'New #{make_caption(opts.singlename)}', functional_area: '#{make_caption(opts.applet)}', program: '#{make_caption(opts.program_text)}'
              # drop_program '#{make_caption(opts.program_text)}', functional_area: '#{make_caption(opts.applet)}'
              drop_functional_area '#{make_caption(opts.applet)}'
            end
          end
        RUBY
      end

      def make_program_menu
        <<~RUBY
          # Save this as something like [db/menu/#{Time.now.strftime('%Y%m%d%H%M')}_#{opts.program}.rb]
          # Or add it to the existing migration for functional area #{make_caption(opts.applet)}.

          # Then run [bundle exec rake menu:migrate]

          Crossbeams::MenuMigrations::Migrator.migration('#{opts.classnames[:roda_class]}') do
            up do
              add_program '#{make_caption(opts.program_text)}', functional_area: '#{make_caption(opts.applet)}', seq: 1
              #{opts.new_from_menu ? '' : '# '}add_program_function 'New #{make_caption(opts.singlename)}', functional_area: '#{make_caption(opts.applet)}', program: '#{make_caption(opts.program_text)}', url: '/#{opts.applet}/#{opts.program}/#{opts.table}/new', seq: 1
              add_program_function 'List #{make_caption(opts.table)}', functional_area: '#{make_caption(opts.applet)}', program: '#{make_caption(opts.program_text)}', url: '/list/#{opts.table}', seq: 2
              # add_program_function 'Search #{make_caption(opts.table)}', functional_area: '#{make_caption(opts.applet)}', program: '#{make_caption(opts.program_text)}', url: '/search/#{opts.table}', seq: 3
            end

            down do
              # drop_program_function 'Search #{make_caption(opts.table)}', functional_area: '#{make_caption(opts.applet)}', program: '#{make_caption(opts.program_text)}'
              # drop_program_function 'List #{make_caption(opts.table)}', functional_area: '#{make_caption(opts.applet)}', program: '#{make_caption(opts.program_text)}'
              # drop_program_function 'New #{make_caption(opts.singlename)}', functional_area: '#{make_caption(opts.applet)}', program: '#{make_caption(opts.program_text)}'
              drop_program '#{make_caption(opts.program_text)}', functional_area: '#{make_caption(opts.applet)}'
            end
          end
        RUBY
      end

      def make_progfunc_menu
        <<~RUBY
          # Save this as something like [db/menu/#{Time.now.strftime('%Y%m%d%H%M')}_#{opts.singlename}.rb]
          # Or add it to the existing migration for functional area #{make_caption(opts.applet)}.
          # Or add it to the existing migration for program #{make_caption(opts.program_text)}.

          # Then run [bundle exec rake menu:migrate]

          Crossbeams::MenuMigrations::Migrator.migration('#{opts.classnames[:roda_class]}') do
            up do
              #{opts.new_from_menu ? '' : '# '}add_program_function 'New #{make_caption(opts.singlename)}', functional_area: '#{make_caption(opts.applet)}', program: '#{make_caption(opts.program_text)}', url: '/#{opts.applet}/#{opts.program}/#{opts.table}/new', seq: 1
              add_program_function 'List #{make_caption(opts.table)}', functional_area: '#{make_caption(opts.applet)}', program: '#{make_caption(opts.program_text)}', url: '/list/#{opts.table}', seq: 2
              # add_program_function 'Search #{make_caption(opts.table)}', functional_area: '#{make_caption(opts.applet)}', program: '#{make_caption(opts.program_text)}', url: '/search/#{opts.table}', seq: 3
            end

            down do
              # drop_program_function 'Search #{make_caption(opts.table)}', functional_area: '#{make_caption(opts.applet)}', program: '#{make_caption(opts.program_text)}'
              drop_program_function 'List #{make_caption(opts.table)}', functional_area: '#{make_caption(opts.applet)}', program: '#{make_caption(opts.program_text)}'
              #{opts.new_from_menu ? '' : '# '}drop_program_function 'New #{make_caption(opts.singlename)}', functional_area: '#{make_caption(opts.applet)}', program: '#{make_caption(opts.program_text)}'
            end
          end
        RUBY
      end

      def check_for_menu_required
        return :function unless DB.select(1).where(DB[:functional_areas].where(functional_area_name: make_caption(opts.applet)).exists).one?
        return :program unless DB.select(1)
                                 .where(DB[:programs]
                                 .where(program_name: make_caption(opts.program_text), functional_area_id: DB[:functional_areas]
                                 .where(functional_area_name: make_caption(opts.applet))
                                 .select(:id))
                                 .exists)
                                 .one?

        :program_function
      end
    end

    class MenuMaker < BaseService
      attr_reader :opts
      def initialize(opts)
        @opts = opts
      end

      def titleize(str)
        str.split(' ').map(&:capitalize).join(' ')
      end

      def make_caption(value)
        opts.inflector.humanize(value.to_s).gsub(/\s\D/, &:upcase)
      end

      def call
        <<~SQL
          -- FUNCTIONAL AREA #{make_caption(opts.applet)}
          INSERT INTO functional_areas (functional_area_name) VALUES ('#{make_caption(opts.applet)}');

          -- PROGRAM: #{make_caption(opts.program_text)}
          INSERT INTO programs (program_name, program_sequence, functional_area_id)
          VALUES ('#{make_caption(opts.program_text)}', 1, (SELECT id FROM functional_areas
                                                        WHERE functional_area_name = '#{make_caption(opts.applet)}'));

          -- LINK program to webapp
          INSERT INTO programs_webapps(program_id, webapp) VALUES (
                (SELECT id FROM programs
                 WHERE program_name = '#{make_caption(opts.program_text)}'
                   AND functional_area_id = (SELECT id FROM functional_areas
                                             WHERE functional_area_name = '#{make_caption(opts.applet)}')),
                 '#{opts.classnames[:roda_class]}');

          -- NEW menu item
          -- PROGRAM FUNCTION New #{opts.classnames[:class]}
          #{opts.new_from_menu ? '' : '/*'}
          INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
          VALUES ((SELECT id FROM programs WHERE program_name = '#{make_caption(opts.program_text)}'
                   AND functional_area_id = (SELECT id FROM functional_areas
                                             WHERE functional_area_name = '#{make_caption(opts.applet)}')),
                   'New #{make_caption(opts.singlename)}', '/#{opts.applet}/#{opts.program}/#{opts.table}/new', 1);
          #{opts.new_from_menu ? '' : '*/'}

          -- LIST menu item
          -- PROGRAM FUNCTION #{opts.table.capitalize}
          INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
          VALUES ((SELECT id FROM programs WHERE program_name = '#{make_caption(opts.program_text)}'
                   AND functional_area_id = (SELECT id FROM functional_areas
                                             WHERE functional_area_name = '#{make_caption(opts.applet)}')),
                   'List #{make_caption(opts.table)}', '/list/#{opts.table}', 2);

          -- SEARCH menu item
          -- PROGRAM FUNCTION Search #{opts.table.capitalize}
          /*
          INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence)
          VALUES ((SELECT id FROM programs WHERE program_name = '#{make_caption(opts.program_text)}'
                   AND functional_area_id = (SELECT id FROM functional_areas
                                             WHERE functional_area_name = '#{make_caption(opts.applet)}')),
                   'Search #{make_caption(opts.table)}', '/search/#{opts.table}', 2);
          */
        SQL
      end
    end
  end
end
# rubocop:enable Metrics/AbcSize
