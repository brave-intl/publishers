# Given a probi integer value, returns the amount to be paid to to the publisher
# and the amount saved as the fee
class PublisherBalanceFeeCalculator < BaseApiClient
  attr_reader :probi

  def initialize(probi:)
    @probi = probi.to_i
  end

  def perform
    fee = (probi * fee_rate).to_i
    balance_after_fee = probi - fee
    
    if balance_after_fee + fee != probi # sanity check
      raise "Balance calculation mismatch. fee: #{fee}, balance_after_fee #{balance_after_fee} probi #{probi}"
    else
      {
        fee: fee, 
        balance_after_fee: probi
      }
    end
  end

  private

  def fee_rate
    raise if Rails.application.secrets[:fee_rate].blank?
    Rails.application.secrets[:fee_rate].to_d
  end
end
