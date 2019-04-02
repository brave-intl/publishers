class TwoFactorAuthenticationRemoval < ApplicationRecord

  # # 2 Weeks represented in seconds
  # TWO_FACTOR_AUTHENTICATION_REMOVAL_WAITING_PERIOD = 1209600
  # # 4 Weeks represented in seconds
  # LOCKED_STATUS_WAITING_PERIOD = 2592000

  # 2 Weeks represented in seconds
  TWO_FACTOR_AUTHENTICATION_REMOVAL_WAITING_PERIOD = 300
  # 4 Weeks represented in seconds
  LOCKED_STATUS_WAITING_PERIOD = 300
  # 6 Weeks represented in seconds
  TOTAL_WAITING_PERIOD = TWO_FACTOR_AUTHENTICATION_REMOVAL_WAITING_PERIOD + LOCKED_STATUS_WAITING_PERIOD

  # Returns time remaining in seconds 
  def total_time_remaining
    time = Time.now
    remainder = TOTAL_WAITING_PERIOD - (time - created_at)
    remainder
  end

  # Returns days remaining in 2fa removal waiting period
  def two_factor_authentication_removal_days_remaining
    time = Time.now
    remainder = TWO_FACTOR_AUTHENTICATION_REMOVAL_WAITING_PERIOD - (time - created_at)
    remainder = remainder / 24 / 3600
    "#{remainder.round} Days"
  end

  # Returns days remaining in locked status waiting period
  def locked_status_days_remaining
    time = Time.now
    remainder = TOTAL_WAITING_PERIOD - (time - created_at)
    if remainder > LOCKED_STATUS_WAITING_PERIOD
      "Not started yet"
    else
      remainder = remainder / 24 / 3600
      "#{remainder.round} Days"
    end
  end

  def two_factor_authentication_removal_time_completed?
    time = Time.now
    remainder = TWO_FACTOR_AUTHENTICATION_REMOVAL_WAITING_PERIOD - (time - created_at)
    puts remainder
    puts "tc? "
    puts remainder <= 0
    remainder <= 0
  end

  def locked_status_time_completed?
    time = Time.now
    remainder = TOTAL_WAITING_PERIOD - (time - created_at)
    remainder <= 0
  end
end
