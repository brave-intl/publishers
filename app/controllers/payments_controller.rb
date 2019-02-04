class PaymentsController < ApplicationController
  before_action :filter_users

  def show
  end

  private

  # Internal: only allow users who are on the new UI whitelist to be allowed to access controller
  #
  # Returns nil
  def filter_users
    raise unless current_user&.in_new_ui_whitelist?
  end
end
