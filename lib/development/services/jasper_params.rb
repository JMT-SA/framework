# frozen_string_literal: true

# Gather settings for a Jasper Report and apply defaults.
class JasperParams
  attr_reader :report_name, :user_name, :params
  attr_accessor :file_name, :mode, :parent_folder, :printer, :return_full_path

  def initialize(report_name, user_name, params = {})
    @report_name = report_name
    @user_name = user_name
    @params = params
    setup_defaults
  end

  private

  def setup_defaults
    @mode = :pdf
    @file_name = report_name
    @parent_folder = nil
    @printer = nil
    @return_full_path = false
  end
end
