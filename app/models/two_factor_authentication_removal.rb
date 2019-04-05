class TwoFactorAuthenticationRemoval < ApplicationRecord
  include ActionView::Helpers::DateHelper
  belongs_to :publisher
  # 2 Weeks represented in seconds
  TWO_FACTOR_AUTHENTICATION_REMOVAL_WAITING_PERIOD = 1209600
  # 4 Weeks represented in seconds
  LOCKED_STATUS_WAITING_PERIOD = 2592000
  # 6 Weeks represented in seconds
  TOTAL_WAITING_PERIOD = TWO_FACTOR_AUTHENTICATION_REMOVAL_WAITING_PERIOD + LOCKED_STATUS_WAITING_PERIOD

  # Returns time remaining as days, hours, minutes, seconds
  def total_time_remaining
    total_seconds = TOTAL_WAITING_PERIOD - (Time.now - created_at)
    distance_of_time_in_words(total_seconds)
  end

  def two_factor_authentication_removal_time_completed?
    (TWO_FACTOR_AUTHENTICATION_REMOVAL_WAITING_PERIOD - (Time.now - created_at)) <= 0
  end

  def locked_status_time_completed?
    (TOTAL_WAITING_PERIOD - (Time.now - created_at)) <= 0
  end

  def two_factor_authentication_removal_days_remaining
    total_seconds = TWO_FACTOR_AUTHENTICATION_REMOVAL_WAITING_PERIOD - (Time.now - created_at)
    distance_of_time_in_words(total_seconds)
  end

  def locked_status_days_remaining
    total_seconds = TOTAL_WAITING_PERIOD - (Time.now - created_at)
    if total_seconds <= LOCKED_STATUS_WAITING_PERIOD
      distance_of_time_in_words(total_seconds)
    else
      "Not started yet"
    end
  end
end
