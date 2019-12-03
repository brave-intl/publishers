module Partners
  class PaymentsController < ApplicationController
    before_action :filter_users

    def show; end

    private

    # Internal: only allow users who are partners to access this UI
    #
    # Returns nil
    def filter_users
      raise unless current_user&.partner?
    end
  end
end
