# frozen_string_literal: true

module DevelopmentApp
  class GenerateNewScriptScaffold < BaseService
    attr_reader :script_class, :description, :reason
    def initialize(params)
      @script_class = params[:script_class]
      @description = params[:description]
      @reason = params[:reason]
    end

    def call
      sources = { path: build_filename }
      sources[:code] = build_code

      sources
    end

    private

    def build_filename
      inflector = Dry::Inflector.new
      "scriptfixes/#{inflector.underscore(script_class)}.rb"
    end

    def build_code
      <<~RUBY
        # frozen_string_literal: true

        # What this script does:
        # ----------------------
        # #{comment_indent(description)}
        #
        # Reason for this script:
        # -----------------------
        # #{comment_indent(reason)}
        #
        # To run:
        # -------
        # Debug : DEBUG=y RACK_ENV=production ruby scripts/base_script.rb #{script_class}
        # Live  : RACK_ENV=production ruby scripts/base_script.rb #{script_class}
        # Dev   : ruby scripts/base_script.rb #{script_class}
        #
        class #{script_class} < BaseScript
          def run
            # Do some work here...

            if debug_mode
              puts "Updated something \#{some_value}: \#{some_change}"
            else
              DB.transaction do
                puts "Updated something \#{some_value}: \#{some_change}"
                DB[:table].where(id: ids).update(attrs)
                # log_status(:table, id, 'FIXED X', comment: 'because y', user_name: 'System')
                # log_multiple_statuses(:table, ids, 'FIXED X', comment: 'because y', user_name: 'System')
              end
            end

            infodump = <<~STR
              Script: #{script_class}

              What this script does:
              ----------------------
              #{indent(description, 6)}

              Reason for this script:
              -----------------------
              #{indent(reason, 6)}

              Results:
              --------
              Updated something

              data: \#{some_data.join(', ')}

              text data:
              \#{some_text_data.join("\\n")}
            STR

            log_infodump(:data_fix,
                         :something,
                         :change_description,
                         infodump)

            if debug_mode
              success_response('Dry run complete')
            else
              success_response('Something was done')
            end
          end
        end
      RUBY
    end

    def indent(text, spaces)
      text.split("\n").map(&:chomp).join(UtilityFunctions.newline_and_spaces(spaces))
    end

    def comment_indent(text)
      text.split("\n").map(&:chomp).join("\n# ")
    end
  end
end
