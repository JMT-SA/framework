# frozen_string_literal: true

module Development
  module Logging
    module QueJob
      class Show
        def self.call(id) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:que_job, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :priority
              form.add_field :run_at
              form.add_field :job_class
              form.add_field :error_count
              form.add_field :last_error_message
              form.add_field :queue
              form.add_field :last_error_backtrace
              form.add_field :finished_at
              form.add_field :expired_at
              form.add_field :args
              form.add_field :data
            end
          end

          layout
        end
      end
    end
  end
end
