module Development
  module Generators
    module General
      class Email
        def self.call
          rules = {
            fields: {
              to: { required: true },
              cc: {},
              subject: { required: true },
              body: { renderer: :textarea, rows: 20, required: true }
            },
            name: 'mail'
          }
          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object OpenStruct.new
            page.form do |form|
              form.action '/development/generators/email_test'
              form.form_id 'mail'
              form.add_field :to
              form.add_field :cc
              form.add_field :subject
              form.add_field :body
            end
          end

          layout
        end
      end
    end
  end
end
