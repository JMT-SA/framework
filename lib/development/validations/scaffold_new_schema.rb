ScaffoldNewSchema = Dry::Validation.Form do
  # configure do
  #   def self.messages
  #     super.merge(
  #       en: { errors: { applet_is_other: 'must be filled-in for applet other' } }
  #     )
  #   end
  # end

  required(:table).filled(:str?)
  required(:applet).filled(:str?)
  required(:other).maybe(:str?)
  required(:program).filled(:str?) # downcase...
  required(:label_field).maybe(:str?)

  # validate(applet_is_other: [:applet, :other]) do |applet, other|
  validate(filled?: [:applet, :other]) do |applet, other|
    applet != 'other' || (!other.nil? && !other.empty?)
  end

  # rule(applet_is_other: [:applet, :other]) do |applet, other|
  #   applet.eql?('other').then(other.filled?)
  # end
end

