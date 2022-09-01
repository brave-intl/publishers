# typed: strict

class PayoutMessage < ApplicationRecord
  belongs_to :payout_report
  belongs_to :publisher
end
