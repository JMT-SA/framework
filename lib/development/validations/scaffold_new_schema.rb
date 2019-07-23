# frozen_string_literal: true

module DevelopmentApp
  ScaffoldNewSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    required(:table, :string).filled
    optional(:other, Types::StrippedString).maybe(:str?)
    required(:program, Types::StrippedString).filled(:str?)
    required(:label_field, Types::StrippedString).maybe(:str?)
    required(:short_name, Types::StrippedString).filled(:str?)
    required(:shared_repo_name, Types::StrippedString).maybe(:str?)
    required(:shared_factory_name, Types::StrippedString).maybe(:str?)
    required(:nested_route_parent, :string).maybe(:str?)
    required(:new_from_menu, :bool).maybe(:bool?)

    required(:applet, :string).filled(:str?).when(eql?: 'other') do
      value(:other).filled?
    end

    # This validation rule also works (applet must be required too)
    # validate(filled?: %i[applet other]) do |applet, other|
    #   applet != 'other' || (!other.nil? && !other.empty?)
    # end
  end
end
